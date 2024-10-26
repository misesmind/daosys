// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {UInt} from "daosys/primitives/UInt.sol";
import {MutableERC2535Layout, IDiamondLoupe} from "daosys/introspection/erc2535/mutable/libs/MutableERC2535Layout.sol";

/*
Each FacetCut struct contains a facet address and array of function selectors that are updated in a diamond.

For each FacetCut struct:

If the action is Add, update the function selector mapping for each functionSelectors item to the facetAddress. If any of the functionSelectors had a mapped facet, revert instead.
If the action is Replace, update the function selector mapping for each functionSelectors item to the facetAddress. If any of the functionSelectors had a value equal to facetAddress or the selector was unset, revert instead.
If the action is Remove, remove the function selector mapping for each functionSelectors item. If any of the functionSelectors were previously unset, revert instead.
 */
/**
 * @title MutableERC2535Repo - Library for atomic storage operations in support of ERC2535.
 * @author mises mind
 * @dev facetAddress operations are segregated from other storage ooperations to optimize conditionals.
 */
library MutableERC2535Repo {

    using MutableERC2535Layout for MutableERC2535Layout.Struct;
    using MutableERC2535Repo for bytes32;
    using UInt for uint256;

    bytes32 internal constant STORAGE_SLOT_OFFSET = keccak256(type(MutableERC2535Layout).creationCode);

    function _layout(
        bytes32 storageRange
    ) internal pure returns(MutableERC2535Layout.Struct storage layout) {
        storageRange ^= STORAGE_SLOT_OFFSET;
        assembly{layout.slot := storageRange}
    }

    function _addFacet(
        bytes32 storageRange,
        IDiamondLoupe.Facet memory facet
    ) internal {
        MutableERC2535Layout.Struct storage layout = storageRange._layout();
        for(uint256 cursor = 0; cursor < facet.functionSelectors.length; cursor++) {
        /*
        If the action is Add, update the function selector mapping for each functionSelectors item to the facetAddress.
        If any of the functionSelectors had a mapped facet, revert instead.
        */
        require(
            layout.facetAddress[facet.functionSelectors[cursor]] == address(0),
            
            string.concat(
                "Function ",
                cursor._toString(),
                " previously set."
            )
        );
        layout.facetAddress[facet.functionSelectors[cursor]] = facet.facetAddress;
        }
        layout._storeFacet(facet);
    }

    function _replaceFacet(
        bytes32 storageRange,
        IDiamondLoupe.Facet memory facet
    ) internal {
        MutableERC2535Layout.Struct storage layout = storageRange._layout();
        for(uint256 cursor = 0; cursor < facet.functionSelectors.length; cursor++) {
        /*
        If the action is Replace, update the function selector mapping for each functionSelectors item to the facetAddress.
        If any of the functionSelectors had a value equal to facetAddress or the selector was unset, revert instead.
        */
        require(
            layout.facetAddress[facet.functionSelectors[cursor]] != address(0)
            ||
            layout.facetAddress[facet.functionSelectors[cursor]] != facet.facetAddress,
            "Function not previously set or redundant."
        );
        layout.facetAddress[facet.functionSelectors[cursor]] = facet.facetAddress;
        }
        // TODO code replacement
        // layout._storeFacet(facet);
    }

    function _removeFacet(
        bytes32 storageRange,
        IDiamondLoupe.Facet memory facet
    ) internal {
        MutableERC2535Layout.Struct storage layout = storageRange._layout();
        for(uint256 cursor = 0; cursor < facet.functionSelectors.length; cursor++) {
        /*
        If the action is Remove, remove the function selector mapping for each functionSelectors item.
        If any of the functionSelectors were previously unset, revert instead.
        */
        require(
            layout.facetAddress[facet.functionSelectors[cursor]] != address(0),
            "Function not previously set."
        );
        layout.facetAddress[facet.functionSelectors[cursor]] = facet.facetAddress;
        }
        layout._removeFacet(facet);
    }

    function _loadFacets(
        bytes32 storageRange
    ) internal view returns(IDiamondLoupe.Facet[] memory allFacets) {
        allFacets = storageRange._layout()._loadFacets();
    }

    function _loadFacetFunctionSelectors(
        bytes32 storageRange,
        address facet
    ) internal view returns(bytes4[] memory facetFunctionSelectors) {
        facetFunctionSelectors = storageRange._layout()._loadFacetFunctionSelectors(facet);
    }

    function _loadFacetAddresses(
        bytes32 storageRange
    ) internal view returns(address[] memory facetAddresses) {
        facetAddresses = storageRange._layout()._loadFacetAddresses();
    }

    function _loadFacetAddress(
        bytes32 storageRange,
        bytes4 func
    ) internal view returns(address facetAddress) {
        facetAddress =  storageRange._layout()._loadFacetAddress(func);
    }

}