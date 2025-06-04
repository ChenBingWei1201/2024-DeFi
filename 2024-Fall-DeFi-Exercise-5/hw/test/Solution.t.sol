// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Challenge.sol";

contract RougeTakeOver is Test {
    address internal owner;
    address internal hacker;

    Vault public vault;

    modifier isHacker() {
        vm.startPrank(hacker);
        _;
        vm.stopPrank();
    }

    function setUp() public {
        owner = makeAddr("owner");
        hacker = makeAddr("hacker");

        vm.prank(owner);
        vault = new Vault("LIAO");
    }

    // Write a fuzzing function that finds a func value that allows the hacker to become the owner.
}
