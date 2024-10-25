// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @title ERC165Utils Standardized operations to support ERC165.
 * @author mises mind <misesmind@proton.me>
 */
library ERC165Utils {

    /**
     * @dev Calculates the ERC165 interface ID for the provided array of function selectors.
     * @dev Useful for when you have the function selectors of a Facet, but not the interface IDs.
     * @param funcs The array of function selectors of which to calculate the ERC165 interface ID.
     * @return interfaceId The calculated ERC165 interface ID.
     */
    function _calcInterfaceId(
        bytes4[] memory funcs
    ) internal pure returns(bytes4 interfaceId) {
        for(uint256 cursor = 0; cursor < funcs.length; cursor++) {
            interfaceId ^= funcs[cursor];
        }
    }

}