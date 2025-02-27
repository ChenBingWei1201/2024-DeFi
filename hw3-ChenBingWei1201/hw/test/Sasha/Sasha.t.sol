// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {SashaBaseTest} from "./SashaBase.t.sol";

import "../../src/interface.sol";

contract SashaTest is SashaBaseTest {
    function testExploit() public validation {
        ERC20(DAI).approve(address(UniRouter), 3 ether);
        address[] memory path = new address[](2);
        path[0] = DAI;
        path[1] = LiaoToken;

        // Swap DAI to LiaoToken on Uniswap
        uint256[] memory amounts = UniRouter.swapExactTokensForTokens(
            3 ether,
            0,
            path,
            arbitrager,
            block.timestamp
        );

        // Swap LiaoToken to DAI on PancakeSwap
        ERC20(LiaoToken).approve(address(PankcakeRouter), amounts[1]);
        address[] memory path_2 = new address[](2);
        path_2[0] = LiaoToken;
        path_2[1] = DAI;

        PankcakeRouter.swapExactTokensForTokens(
            amounts[1],
            0,
            path_2,
            arbitrager,
            block.timestamp
        );
    }
}
