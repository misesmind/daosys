// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import {Uint512, BetterMath} from "contracts/math/BetterMath.sol";

library BetterUniV2Utils {

    using BetterMath for uint256;

    uint internal constant _MINIMUM_LIQUIDITY = 10**3;

    /**
     * @dev Provides the LP token mint amount for a given depoosit, reserve, and total supply.
     */
    function _calcDeposit(
        uint256 amountADeposit,
        uint256 amountBDeposit,
        uint256 lpTotalSupply,
        uint256 lpReserveA,
        uint256 lpReserveB
    ) internal pure returns(uint256 lpAmount) {
         lpAmount = lpTotalSupply == 0
            ? BetterMath._sqrt((amountADeposit * amountBDeposit)) - _MINIMUM_LIQUIDITY
            : BetterMath._min(
                (amountADeposit * lpTotalSupply) / lpReserveA,
                (amountBDeposit * lpTotalSupply) / lpReserveB
            );
    }

    /**
     * @dev Provides the owned balances of a given liquidity pool reserve.
     */
    function _calcWithdraw(
        uint256 ownedLPAmount,
        uint256 lpTotalSupply,
        uint256 totalReserveA,
        uint256 totalReserveB
    ) internal pure returns(
        uint256 ownedReserveA,
        uint256 ownedReserveB
    ) {
        ownedReserveA = ((ownedLPAmount * totalReserveA) / lpTotalSupply);
        ownedReserveB = ((ownedLPAmount * totalReserveB) / lpTotalSupply);
    }

    function _calcReserveShare(
        uint256 ownedLPAmount,
        uint256 lpTotalSupply,
        uint256 totalReserveA
    ) internal pure returns(uint256 ownedReserveA) {
        ownedReserveA = ((ownedLPAmount * totalReserveA) / lpTotalSupply);
    }

    /**
     * @dev Provides the owned balances of a given liquidity pool reserve.
     */
    function _calcReserveShares(
        uint256 ownedLPAmount,
        uint256 lpTotalSupply,
        uint256 totalReserveA,
        uint256 totalReserveB
    ) internal pure returns(
        uint256 ownedReserveA,
        uint256 ownedReserveB
    ) {
        // using balances ensures pro-rata distribution
        ownedReserveA = ((ownedLPAmount * totalReserveA) / lpTotalSupply);
        ownedReserveB = ((ownedLPAmount * totalReserveB) / lpTotalSupply);
    }

    // tag::_quote[]
    /**
     * @dev Given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
     */
    function _calcEquiv(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) internal pure returns (uint amountB) {
        require(amountA > 0, "UniV2Utils: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniV2Utils: INSUFFICIENT_LIQUIDITY");
        amountB = (amountA * reserveB) / reserveA;
    }
    // end::_quote[]

    // tag::_quoteSwapOut[]
    /**
     * @dev Provides the sale amount for a desired proceeds amount.
     * @param amountOut The desired swap proceeds.
     * @param reserveIn The LP reserve of the sale token.
     * @param reserveOut The LP reserve of the proceeds tokens.
     * @return amountIn The amount of token to sell to get the desired proceeds.
     */
    function _calcSaleAmount(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountIn) {
        // TODO refactor to custom error
        require(amountOut > 0, "BetterUniV2Utils: INSUFFICIENT_OUTPUT_AMOUNT");
        // TODO refactor to custom error
        require(
            reserveIn > 0
            && reserveOut > 0,
            "BetterUniV2Utils: INSUFFICIENT_LIQUIDITY"
        );
        uint numerator = (reserveIn * amountOut) * (1000);
        uint denominator = (reserveOut - amountOut) * (997);
        amountIn = (numerator / denominator) + (1);
    }
    // end::_quoteSwapOut[]

    // tag::_quoteSwapIn[]
    /**
     * @dev Provides the proceeds of a sale of a provided amount.
     * @param amountIn The amount of token for which too quote a sale.
     * @param reserveIn The LP reserve of the sale token.
     * @param reserveOut The LP reserve of the proceeds tokens.
     * @return amountOut The proceeds of selling `amountin`.
     */
    function _calcSaleProceeds(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountOut) {
        // console.log("enter _calcSaleProceeds");
        // TODO refactor to custom error
        // console.log("amountIn = %s", amountIn);
        require(amountIn > 0, "BetterUniV2Utils: INSUFFICIENT_INPUT_AMOUNT");
        // TODO refactor to custom error
        // console.log("reserveIn = %s", reserveIn);
        // console.log("reserveOut = %s", reserveOut);
        require(
            reserveIn > 0 
            && reserveOut > 0,
            "BetterUniV2Utils: INSUFFICIENT_LIQUIDITY"
        );
        uint amountInWithFee = (amountIn * 997);
        // console.log("amountInWithFee = %s", amountInWithFee);
        uint numerator = (amountInWithFee * reserveOut);
        // console.log("numerator = %s", numerator);
        uint denominator = (reserveIn * 1000) + (amountInWithFee);
        // console.log("denominator = %s", denominator);
        amountOut = numerator / denominator;
        // console.log("amountOut = %s", amountOut);
        // console.log("exit _calcSaleProceeds");
    }
    // end::_quoteSwapIn[]

    function _calcSingleReserveShares(
        uint256 ownedLPAmount,
        uint256 lpTotalSupply,
        uint256 totalReserveA
    ) internal pure returns(
        uint256 ownedReserveA
    ) {
        // using balances ensures pro-rata distribution
        ownedReserveA = ((ownedLPAmount * totalReserveA) / lpTotalSupply);
        // ownedReserveB = ((ownedLPAmount * totalReserveB) / lpTotalSupply);
    }

    /**
     * @dev Calculates the amount of LP to withdraw to extract a desired amount of one token.
     * @dev Could be done more efficiently with optimized math.
     */
    // TODO Optimize math.
    function _calcWithdrawAmt(
        uint256 targetOutAmt,
        uint256 lpTotalSupply,
        uint256 outRes,
        uint256 opRes
    ) internal pure returns(uint256 lpWithdrawAmt) {
        // console.log("enter _calcWithdrawAmt");
        // console.log("targetOutAmt = %s", targetOutAmt);
        // console.log("lpTotalSupply = %s", lpTotalSupply);
        // console.log("outRes = %s", outRes);
        // console.log("opRes = %s", opRes);
        uint256 opTAmt = _calcEquiv(
            targetOutAmt,
            outRes,
            opRes
        );
        // console.log("opTAmt = %s", opTAmt);
        lpWithdrawAmt = _calcDeposit(
            targetOutAmt,
            opTAmt,
            // _calcEquiv(
            //     targetOutAmt,
            //     outRes,
            //     opRes
            // ),
            lpTotalSupply,
            outRes,
            opRes
        );
        // console.log("lpWithdrawAmt = %s", lpWithdrawAmt);
        // console.log("exit _calcWithdrawAmt");
    }

    function _calcSwapDepositAmtIn(
        uint256 userIn,
        uint256 reserveIn
    ) internal pure returns (uint256 swapAmount_) {
      return (
            BetterMath._sqrt(
                reserveIn 
                * (
                    (userIn * 3988000) + (reserveIn * 3988009)
                )
            ) - (reserveIn * 1997)
        ) / 1994;
    }

    function _calcSwapDeposit(
        uint256 saleTokenAmount,
        uint256 lpTotalSupply,
        uint256 saleTokenReserve,
        uint256 opposingTokenReserve
    ) internal pure returns(uint256 lpProceeds) {
        // uint256 amountToSwap = _calcSwapDepositAmtIn(saleTokenReserve, saleTokenAmount);
        uint256 amountToSwap = _calcSwapDepositAmtIn(saleTokenAmount, saleTokenReserve);
        uint256 saleTokenDeposit = saleTokenAmount - amountToSwap;
        uint256 opposingTokenDeposit = _calcSaleProceeds(
            amountToSwap,
            saleTokenReserve,
            opposingTokenReserve
        );

        lpProceeds = _calcDeposit(
            saleTokenDeposit,
            opposingTokenDeposit,
            // IUniswapV2Pair(pair).totalSupply(),
            lpTotalSupply,
            saleTokenReserve + amountToSwap,
            opposingTokenReserve - opposingTokenDeposit
        );
    }

}