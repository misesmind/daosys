// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {IERC20, SafeERC20} from "contracts/tokens/erc20/libs/SafeERC20.sol";
import {IUniswapV2Pair} from "../interfaces/IUniswapV2Pair.sol";
import {BetterUniV2Utils} from "./BetterUniV2Utils.sol";

library BetterUniV2Service {

    using BetterUniV2Utils for uint256;
    using BetterUniV2Service for IUniswapV2Pair;
    using SafeERC20 for IERC20;

    function _correlateAmounts(
        IUniswapV2Pair pair,
        IERC20 knownToken,
        uint256 token0Amount,
        uint256 token1Amount
    ) internal view returns(
        uint256 knownTokenAmount,
        IERC20 opposingToken_,
        uint256 opposingTokenAmount
    ) {
        address token0 = IUniswapV2Pair(pair).token0();
        (
            knownTokenAmount,
            opposingToken_,
            opposingTokenAmount
        ) = address(knownToken) == token0
            ? (token0Amount, IERC20(IUniswapV2Pair(pair).token1()), token1Amount)
            : (token1Amount, IERC20(token0), token0Amount);
    }

    function _depositDirect(
        IUniswapV2Pair pair,
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 tokenAAmount,
        uint256 tokenBAmount
    ) internal returns (uint256 lpTokenAmount) {
        tokenA._safeTransfer(address(pair), tokenAAmount);
        tokenB._safeTransfer(address(pair), tokenBAmount);
        lpTokenAmount = pair.mint(address(this));
    }

    function _withdrawDirect(
        IUniswapV2Pair pool,
        uint256 amt
    ) internal returns(uint amount0, uint amount1) {
        pool.transfer(address(pool), amt);
        (amount0, amount1) = pool.burn(address(this));
    }

    function _withdrawSwapDirectTo(
        IUniswapV2Pair pool,
        uint256 amt,
        IERC20 tokenOut,
        IERC20 opToken,
        address recipient
    ) internal returns(uint256 amountOut) {
        (uint amount0, uint amount1) = pool
        ._withdrawDirect(amt);
        address token0 = pool.token0();

        (
            uint256 tokenOutWDAmt,
            uint256 saleTokenWDAmt
        ) = address(tokenOut) == address(token0)
            ? (amount0, amount1)
            : (amount1, amount0);
        (uint256 proceedsAmount) = pool
        ._swapDirect(opToken, saleTokenWDAmt);
        amountOut = (tokenOutWDAmt + proceedsAmount);
        tokenOut._safeTransfer(recipient, amountOut);
    }

    function withdrawSwapDirectTo(
        IUniswapV2Pair pool,
        uint256 amt,
        IERC20 tokenOut,
        IERC20 opToken,
        address recipient
    ) external returns(uint256 proceedsAmount) {
        return _withdrawSwapDirectTo(
            pool,
            amt,
            tokenOut,
            opToken,
            recipient
        );
    }

    function _swapDirect(
        IUniswapV2Pair pair,
        IERC20 soldToken,
        uint amountToSell
    ) internal returns(uint256 proceedsAmount) {
        (
            uint256 totalReserve0,
            uint256 totalReserve1,

        ) = pair.getReserves();


        address token0 = pair.token0();

        (
            uint256 soldTokenReserve,
            uint256 proceedsTokenReserve
        ) = address(soldToken) == address(token0)
            ? (totalReserve0, totalReserve1)
            : (totalReserve1, totalReserve0);

        proceedsAmount = amountToSell
        ._calcSaleProceeds(
            soldTokenReserve,
            proceedsTokenReserve
        );

        (
            uint256 amount0Out,
            uint256 amount1Out
        ) = address(soldToken) == address(token0)
            ? (uint256(0), proceedsAmount)
            : (proceedsAmount, uint256(0));

        IERC20(soldToken)
            ._safeTransfer(address(pair), amountToSell);
        pair.swap(amount0Out, amount1Out, address(this), new bytes(0));
    }

    function _swapDepositDirect(
        IUniswapV2Pair pair,
        IERC20 saleToken,
        uint256 saleTokenAmount,
        uint256 saleTokenReserve,
        IERC20 opposingToken_
    ) internal returns(uint256 lpTokenAmount) {
        // uint256 amountToSwap = saleTokenReserve
        //     ._calcSwapDepositAmtIn(saleTokenAmount);
        uint256 amountToSwap = saleTokenAmount
            ._calcSwapDepositAmtIn(saleTokenReserve);
        uint256 opposingTokenAmount = pair._swapDirect(
            saleToken,
            amountToSwap
        );
        lpTokenAmount = pair._depositDirect(
            saleToken,
            opposingToken_,
            (saleTokenAmount - amountToSwap),
            opposingTokenAmount
        );
    }

    function _depositDirectTo(
        IUniswapV2Pair pair,
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 tokenAAmount,
        uint256 tokenBAmount,
        address recipient
    ) internal returns (uint256 lpTokenAmount) {
        tokenA._safeTransfer(address(pair), tokenAAmount);
        tokenB._safeTransfer(address(pair), tokenBAmount);
        lpTokenAmount = pair.mint(recipient);
    }

    function _swapDepositDirectTo(
        IUniswapV2Pair pair,
        IERC20 saleToken,
        uint256 saleTokenAmount,
        uint256 saleTokenReserve,
        IERC20 opposingToken_,
        address recipient
    ) internal returns(uint256 lpTokenAmount) {
        // uint256 amountToSwap = saleTokenReserve
        //     ._calcSwapDepositAmtIn(saleTokenAmount);
        uint256 amountToSwap = saleTokenAmount
            ._calcSwapDepositAmtIn(saleTokenReserve);
        uint256 opposingTokenAmount = pair._swapDirect(
            saleToken,
            amountToSwap
        );
        lpTokenAmount = pair._depositDirectTo(
            saleToken,
            opposingToken_,
            (saleTokenAmount - amountToSwap),
            opposingTokenAmount,
            recipient
        );
    }

    function swapDepositDirectTo(
        IUniswapV2Pair pair,
        IERC20 saleToken,
        uint256 saleTokenAmount,
        uint256 saleTokenReserve,
        IERC20 opposingToken_,
        address recipient
    ) external returns(uint256 lpTokenAmount) {
        return _swapDepositDirectTo(
            pair,
            saleToken,
            saleTokenAmount,
            saleTokenReserve,
            opposingToken_,
            recipient
        );
    }

}