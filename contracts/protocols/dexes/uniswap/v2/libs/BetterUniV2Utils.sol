// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import "contracts/math/BetterMath.sol";

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

    // tag::_calcWithdraw[]
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
    // end::_calcWithdraw[]

    function _calcReserveShare(
        uint256 ownedLPAmount,
        uint256 lpTotalSupply,
        uint256 totalReserveA
    ) internal pure returns(uint256 ownedReserveA) {
        ownedReserveA = ((ownedLPAmount * totalReserveA) / lpTotalSupply);
    }

    // tag::_calcReserveShares[]
    /**
     * @dev Provides the owned balances of a given liquidity pool reserve.
     * @dev Uses A/B nomenclature to indicate order DOES NOT matter, simply correlate variables to the same tokens.
     * @param ownedLPAmount Owned amount of LP token.
     * @param lpTotalSupply LP token total supply.
     * @param totalReserveA LP reserve of Token A
     * @param totalReserveB LP reserve of Token B.
     * @return ownedReserveA Owned share of Token A from LP reserve.
     * @return ownedReserveB Owned share of Token B from LP reserve.
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
    // end::_calcReserveShares[]

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
     * @return amountOut The proceeds of selling `amountIn`.
     */
    function _calcSaleProceeds(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountOut) {
        require(
            amountIn > 0,
            "BetterUniV2Utils: INSUFFICIENT_INPUT_AMOUNT"
        );
        require(
            reserveIn > 0 
            && reserveOut > 0,
            "BetterUniV2Utils: INSUFFICIENT_LIQUIDITY"
        );
        uint amountInWithFee = (amountIn * 997);
        uint numerator = (amountInWithFee * reserveOut);
        uint denominator = (reserveIn * 1000) + (amountInWithFee);
        amountOut = numerator / denominator;
    }
    // end::_quoteSwapIn[]

    function _calcSingleReserveShares(
        uint256 ownedLPAmount,
        uint256 lpTotalSupply,
        uint256 totalReserveA
    ) internal pure returns(
        uint256 ownedReserveA
    ) {
        ownedReserveA = ((ownedLPAmount * totalReserveA) / lpTotalSupply);
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
        uint256 opTAmt = _calcEquiv(
            targetOutAmt,
            outRes,
            opRes
        );
        lpWithdrawAmt = _calcDeposit(
            targetOutAmt,
            opTAmt,
            lpTotalSupply,
            outRes,
            opRes
        );
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
            lpTotalSupply,
            saleTokenReserve + amountToSwap,
            opposingTokenReserve - opposingTokenDeposit
        );
    }

}