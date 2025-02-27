// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract Lender is ReentrancyGuard, Ownable {
    // State Variables
    address[] public allowedTokens;
    mapping(address => address) public tokenToPriceFeed;
    mapping(address => mapping(address => uint256)) public accountToTokenDeposits;
    mapping(address => mapping(address => uint256)) public accountToTokenBorrows;

    // Constant Variable
    uint256 public constant LIQUIDATION_REWARD = 5; // 5% Liquidation Reward
    uint256 public constant LIQUIDATION_FACTOR = 80; // At 80% Loan to Value Ratio, the loan can be liquidated
    uint256 public constant CLOSE_FACTOR = 50; // Only 50% of asset can be liquidated at one time
    uint256 public constant MIN_HEALTH_FACTOR = 1e18;

    // Events
    event AllowedTokenConfiguration(address indexed token, address indexed priceFeed);
    event TokenSupply(address indexed account, address indexed token, uint256 indexed amount);
    event TokenBorrow(address indexed account, address indexed token, uint256 indexed amount);
    event TokenWithdraw(address indexed account, address indexed token, uint256 indexed amount);
    event TokenRepay(address indexed account, address indexed token, uint256 indexed amount);
    event Liquidate(
        address indexed account,
        address indexed repayToken,
        address indexed rewardToken,
        uint256 halfDebtInEth,
        address liquidator
    );

    // Errors
    error TransferFailed();
    error TokenNotAllowed(address token);
    error NeedsMoreThanZero();

    // Constructor
    constructor() Ownable(msg.sender) {}

    function setAllowedToken(address token, address priceFeed) external onlyOwner {
        allowedTokens.push(token);
        tokenToPriceFeed[token] = priceFeed;
        emit AllowedTokenConfiguration(token, priceFeed);
    }

    function supply(address token, uint256 amount) external nonReentrant {
        if (amount == 0) revert NeedsMoreThanZero();
        require(tokenToPriceFeed[token] != address(0), "Token Not Allowed");

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        accountToTokenDeposits[msg.sender][token] += amount;

        emit TokenSupply(msg.sender, token, amount);
    }

    function withdraw(address token, uint256 amount) external nonReentrant {
        if (amount == 0) revert NeedsMoreThanZero();
        require(tokenToPriceFeed[token] != address(0), "Token Not Allowed");
        require(accountToTokenDeposits[msg.sender][token] >= amount, "Insufficient Funds");

        accountToTokenDeposits[msg.sender][token] -= amount;
        IERC20(token).transfer(msg.sender, amount);

        require(healthFactor(msg.sender) >= MIN_HEALTH_FACTOR, "Insolvency Risk");

        emit TokenWithdraw(msg.sender, token, amount);
    }

    function borrow(address token, uint256 amount) external nonReentrant {
        if (amount == 0) revert NeedsMoreThanZero();
        require(tokenToPriceFeed[token] != address(0), "Token Not Allowed");
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient borrowable tokens");

        uint256 collateralValue = viewCollateral(msg.sender);
        uint256 debtValue = viewDebt(msg.sender) + getValueInETH(token, amount);

        // collateral factor = dabtValue / collateralValue <= LIQUIDATION_FACTOR / 100
        require(debtValue <= collateralValue * LIQUIDATION_FACTOR / 100, "Insolvency Risk");

        accountToTokenBorrows[msg.sender][token] += amount;
        IERC20(token).transfer(msg.sender, amount);

        emit TokenBorrow(msg.sender, token, amount);
    }

    function repay(address token, uint256 amount) external nonReentrant {
        if (amount == 0) revert NeedsMoreThanZero();
        require(accountToTokenBorrows[msg.sender][token] >= amount, "Token Not Allowed");
        if (tokenToPriceFeed[token] == address(0)) revert TokenNotAllowed(token);

        accountToTokenBorrows[msg.sender][token] -= amount;
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        emit TokenRepay(msg.sender, token, amount);
    }

    function liquidate(address account, address repayToken, address rewardToken) external nonReentrant {
        if (tokenToPriceFeed[repayToken] == address(0) || tokenToPriceFeed[rewardToken] == address(0)) revert TokenNotAllowed(repayToken);

        uint256 debt = accountToTokenBorrows[account][repayToken];
        uint256 liquidableDebt = debt * CLOSE_FACTOR / 100;
        uint256 rewardValueInETH = getValueInETH(repayToken, liquidableDebt) * LIQUIDATION_REWARD / 100;
        uint256 rewardAmount = getTokenValueFromEth(rewardToken, rewardValueInETH + getValueInETH(repayToken, liquidableDebt));

        accountToTokenBorrows[account][repayToken] -= liquidableDebt;
        IERC20(repayToken).transferFrom(msg.sender, address(this), liquidableDebt);
        IERC20(rewardToken).transfer(msg.sender, rewardAmount);

        emit Liquidate(account, repayToken, rewardToken, liquidableDebt, msg.sender);
    }

    function viewCollateral(address user) public view returns (uint256) {
        uint256 totalCollateralValue = 0;
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            address token = allowedTokens[i];
            uint256 amount = accountToTokenDeposits[user][token];
            totalCollateralValue += getValueInETH(token, amount);
        }
        return totalCollateralValue;
    }

    function viewDebt(address user) public view returns (uint256) {
        uint256 totalDebtValue = 0;
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            address token = allowedTokens[i];
            uint256 amount = accountToTokenBorrows[user][token];
            totalDebtValue += getValueInETH(token, amount);
        }
        return totalDebtValue;
    }

    function getValueInETH(address token, uint256 amount) public view returns (uint256) {
        (, int256 price, , ,) = AggregatorV3Interface(tokenToPriceFeed[token]).latestRoundData();
        return uint256(price) * amount / 1e18;
    }

    function getTokenValueFromEth(address token, uint256 totalValueInETH) public view returns (uint256) {
        (, int256 price, , ,) = AggregatorV3Interface(tokenToPriceFeed[token]).latestRoundData();
        return totalValueInETH * 1e18 / uint256(price);
    }

    function healthFactor(address account) public view returns (uint256) {
        uint256 totalCollateralValue = viewCollateral(account) * LIQUIDATION_FACTOR / 100;
        uint256 totalDebtValue = viewDebt(account);
        if (totalDebtValue == 0) return 100e18;
        return totalCollateralValue * 1e18 / totalDebtValue;
    }
}