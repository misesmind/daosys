// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {AddressSet, AddressSetRepo} from "daosys/collections/sets/AddressSetRepo.sol";
import {FacetSetLayout, IDiamondLoupe} from "daosys/introspection/erc2535/mutable/libs/FacetSetLayout.sol";
import {IDiamondLoupe} from "daosys/introspection/erc2535/interfaces/IDiamondLoupe.sol";


struct MutableERC253Struct {
FacetSetLayout.Struct facets;
mapping(address facet => bytes4[] functionSelectors) facetFunctionSelectors;
AddressSet facetAddresses;
mapping(bytes4 functionSelector => address facet) facetAddress;
}

library MutableERC2535Layout {

    using AddressSetRepo for AddressSet;
    using FacetSetLayout for FacetSetLayout.Struct;

//   struct Struct {
//     FacetSetLayout.Struct facets;
//     mapping(address facet => bytes4[] functionSelectors) facetFunctionSelectors;
//     AddressSet facetAddresses;
//     mapping(bytes4 functionSelector => address facet) facetAddress;
//   }

    // tag::slot[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     * @custom:sig slot(ERC20Struct storage)
     * @custom:selector 0x5bbea693
     */
    function slot(
        MutableERC253Struct storage table
    ) external pure returns(bytes32 slot_) {
        return _slot(table);
    }
    // end::slot[]

    // tag::_slot[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     */
    function _slot(
        MutableERC253Struct storage table
    ) internal pure returns(bytes32 slot_) {
        assembly{slot_ := table.slot}
    }
    // end::_slot[]

    // tag::layout[]
    /**
     * @dev "Binds" this struct to a storage slot.
     * @param slot_ The first slot to use in the range of slots used by the struct.
     * @return layout_ A struct from a Layout library bound to the provided slot.
     * @custom:sig layout(bytes32)
     * @custom:selector 0x81366cef
     */
    function layout(
        bytes32 slot_
    ) external pure returns(MutableERC253Struct storage layout_) {
        return _layout(slot_);
    }
    // end::layout[]

    // tag::_layout[]
    /**
     * @dev "Binds" this struct to a storage slot.
     * @param slot_ The first slot to use in the range of slots used by the struct.
     * @return layout_ A struct from a Layout library bound to the provided slot.
     */
    function _layout(
        bytes32 slot_
    ) internal pure returns(MutableERC253Struct storage layout_) {
        assembly{layout_.slot := slot_}
    }
    // end::_layout[]

//   function _storeFacet(
//     MutableERC2535Layout.Struct storage layout,
//     IDiamondLoupe.Facet memory facet
//   ) internal {
//     layout.facets._add(facet);
//     layout.facetFunctionSelectors[facet.facetAddress] = facet.functionSelectors;
//     layout.facetAddresses._add(facet.facetAddress);
//   }

//   function _removeFacet(
//     MutableERC2535Layout.Struct storage layout,
//     IDiamondLoupe.Facet memory facet
//   ) internal {
//     layout.facets._remove(facet.facetAddress);
//     // Does not actually delete values, just unmaps storage pointer.
//     delete layout.facetFunctionSelectors[facet.facetAddress];
//     layout.facetAddresses._remove(facet.facetAddress);
//   }

//   function _loadFacets(
//     MutableERC2535Layout.Struct storage layout
//   ) internal view returns(IDiamondLoupe.Facet[] memory allFacets) {
//     allFacets = layout.facets._setAsArray();
//   }

//   function _loadFacetFunctionSelectors(
//     MutableERC2535Layout.Struct storage layout,
//     address facetAddress
//   ) internal view returns(bytes4[] memory facetFunctionSelectors) {
//     facetFunctionSelectors = layout.facetFunctionSelectors[facetAddress];
//   }

//   function _loadFacetAddresses(
//     MutableERC2535Layout.Struct storage layout
//   ) internal view returns(address[] memory facetAddresses) {
//     facetAddresses = layout.facetAddresses._asArray();
//   }

//   function _storeFacetAddress(
//     MutableERC2535Layout.Struct storage layout,
//     bytes4 functionSelector,
//     address facetAddress
//   ) internal {
//     layout.facetAddress[functionSelector] = facetAddress;
//   }

//   function _loadFacetAddress(
//     MutableERC2535Layout.Struct storage layout,
//     bytes4 functionSelector
//   ) internal view returns(address facetAddress) {
//     facetAddress = layout.facetAddress[functionSelector];
//   }

}