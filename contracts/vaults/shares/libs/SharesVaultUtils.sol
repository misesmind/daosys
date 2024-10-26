// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BetterMath} from "daosys/math/BetterMath.sol";

/**
 * @title SharesVautlUtils - Utility functions for shares based vaults.
 * @author misesmind <misesmind@proton.me>
 * @notice Provides commons functions fo vaults that use a variable supply of shares.
 * @notice Shares based vault can be seen in ERC4626, and LP tokens.
 */
library SharesVaultUtils {

    using BetterMath for uint256;

    // tag::_decimalsOffset()[]
    /**
     * @return The precision offset to use with the underlying asset used as the underlying reserve.
     */
    function _decimalsOffset()
    internal pure returns (uint8) {
        // Return the default precision offset.
        return 0;
        // return 1;
    }
    // end::_decimalsOffset()[]

    // tag::_convertToShares(uint256,uint256)[]
    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     * @param assets The amount of assets from which to calculate equivalent shares.
     * @param reserve The reserve amount of which to calculate shares.
     * @return shares The equivalent amount of shares for `assets` of `reserve`.
     */
    function _convertToShares(
        uint256 assets,
        uint256 reserve,
        uint256 totalShares
    ) internal pure returns (uint256 shares) {
        shares = _convertToShares(
            assets,
            reserve,
            totalShares,
            _decimalsOffset(),
            BetterMath.Rounding.Floor
        );
    }
    // end::_convertToShares(uint256,uint256)[]

    // tag::_convertToShares(uint256,uint256)[]
    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     * @param assets The amount of assets from which to calculate equivalent shares.
     * @param reserve The reserve amount of which to calculate shares.
     * @return shares The equivalent amount of shares for `assets` of `reserve`.
     */
    function _convertToShares(
        uint256 assets,
        uint256 reserve,
        uint256 totalShares,
        uint8 deccimalOffset
    ) internal pure returns (uint256 shares) {
        shares = _convertToShares(
            assets,
            reserve,
            totalShares,
            deccimalOffset,
            BetterMath.Rounding.Floor
        );
    }
    // end::_convertToShares(uint256,uint256)[]

    // tag::_convertToShares(uint256,uint256,Math.Rounding)[]
    /**
     * @dev Internal conversion function (from assets to shares) with support for rounding direction.
     * @param assets The amount of assets from which to calculate equivalent sharres.
     * @param reserve The reserve amount of which to calculate shares.
     * @param rounding The desired rounding to apply to calculated `shares`
     * @return shares The equivalent amount of shares for `assets` of `reserve`.
     */
    function _convertToShares(
        uint256 assets,
        uint256 reserve,
        uint256 totalShares,
        uint8 deccimalOffset,
        BetterMath.Rounding rounding
    ) internal pure returns (uint256 shares) {
        shares = assets._mulDiv(
            // Offset the decimals to minimize frontrun attacks.
            totalShares + 10 ** deccimalOffset,
            reserve + 1, 
            rounding
        );
    }
    // end::_convertToShares(uint256,uint256,Math.Rounding)[]

    // tag::_convertToAssets(uint256,uint256)[]
    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     * @param shares The amount of shares from which to calculate the equivalent assets.
     * @param reserve The reserve amount of which to calculate assets.
     * @return The equivalent amount of assets for `shares` of `reserve`.
     */
    function _convertToAssets(
        uint256 shares,
        uint256 reserve,
        uint256 totalShares
    ) internal pure returns (uint256) {
        return _convertToAssets(
            shares,
            reserve,
            totalShares,
            _decimalsOffset(),
            BetterMath.Rounding.Floor
        );
    }
    // end::_convertToAssets(uint256,uint256)[]

    // tag::_convertToAssets(uint256,uint256)[]
    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     * @param shares The amount of shares from which to calculate the equivalent assets.
     * @param reserve The reserve amount of which to calculate assets.
     * @return The equivalent amount of assets for `shares` of `reserve`.
     */
    function _convertToAssets(
        uint256 shares,
        uint256 reserve,
        uint256 totalShares,
        uint8 deccimalOffset
    ) internal pure returns (uint256) {
        return _convertToAssets(
            shares,
            reserve,
            totalShares,
            deccimalOffset,
            BetterMath.Rounding.Floor
        );
    }
    // end::_convertToAssets(uint256,uint256)[]
    
    // tag::_convertToAssets(uint256,uint256,Math.Rounding)[]
    /**
     * @dev Internal conversion function (from shares to assets) with support for rounding direction.
     * @param shares The amount of shares from which to calculate the equivalent assets.
     * @param reserve The reserve amount of which to calculate assets.
     * @param rounding The desired rounding to apply to calculated `shares`
     * @return The equivalent amount of assets for `shares` of `reserve`.
     */
    function _convertToAssets(
        uint256 shares,
        uint256 reserve,
        uint256 totalShares,
        uint8 deccimalOffset,
        BetterMath.Rounding rounding
    ) internal pure returns (uint256) {
        // Calculate the amount of asset due for a given amount of shares.
        // Multiply the shares quote by the reserve, then divide by the total shares.
        return shares._mulDiv(
            reserve + 1,
            // Undo the precision offset done during shares conversion.
            totalShares + 10 ** deccimalOffset,
            rounding
        );
    }
    // end::_convertToAssets(uint256,uint256,Math.Rounding)[]

}