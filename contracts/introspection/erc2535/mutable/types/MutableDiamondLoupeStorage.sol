// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {
    MutableERC2535Service,
    MutableDiamondLoupeStorage,
    IDiamondLoupe
} from "./MutableDiamondLoupeStorage.sol";
import {
    MutableERC165Storage
} from "../../../erc165/mutable/types/MutableERC165Storage.sol";

abstract contract MutableDiamondLoupeStorage is MutableERC165Storage {

    using ERC165Utils for bytes4[];
    using MutableERC2535Service for bytes4;
    using MutableERC2535Service for IDiamond.FacetCut;
    using MutableERC2535Service for IDiamond.FacetCut[];
    using MutableERC2535Service for IDiamondLoupe.Facet;

    function _processFacetCuts(
        IDiamond.FacetCut[] memory facetCuts
    ) internal {
        facetCuts._processFacetCuts();
    }

    function _processFacetCut(
        IDiamond.FacetCut memory facetCut
    ) internal {
        facetCut._processFacetCut();
    }

    function _addFacet(
        IDiamondLoupe.Facet memory facet
    ) internal {
        facet._addFacet();
        // facet.functionSelectors._calcInterfaceId()._registerInterfaceSupport();
        // FIXME
        // _registerInterfaceSupport(facet.functionSelectors._calcInterfaceId());
    }

    function _replaceFacet(
        IDiamondLoupe.Facet memory facet
    ) internal {
        facet._replaceFacet();
        // ERC165 state update not required because it does not care about implementation address.
    }

    function _removeFacet(
        IDiamondLoupe.Facet memory facet
    ) internal {
        facet._removeFacet();
    }

    /**
     * @notice Gets all facet addresses and their four byte function selectors.
     * @return facets_ Facet
     */
    function _facets() internal view returns (IDiamondLoupe.Facet[] memory facets_) {
        facets_ = MutableERC2535Service._facets();
    }

    /**
     * @notice Gets all the function selectors supported by a specific facet.
     * @param _facet The facet address.
     * @return facetFunctionSelectors_
     */
    function _facetFunctionSelectors(
        address _facet
    ) internal view returns (bytes4[] memory facetFunctionSelectors_) {
        facetFunctionSelectors_ = MutableERC2535Service._facetFunctionSelectors(_facet);
    }

    /**
     * @notice Get all the facet addresses used by a diamond.
     * @return facetAddresses_
     */
    function _facetAddresses()
    internal view returns (address[] memory facetAddresses_) {
        facetAddresses_ = MutableERC2535Service._facetAddresses();
    }

    /**
     * @notice Gets the facet that supports the given selector.
     * @dev If facet is not found return address(0).
     * @param _functionSelector The function selector.
     * @return facetAddress_ The facet address.
     */
    function _facetAddress(
        bytes4 _functionSelector
    ) internal view virtual returns (address facetAddress_) {
        facetAddress_ = _functionSelector._facetAddress();
    }

}