// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {AddressSet, AddressSetRepo} from "daosys/collections/sets/AddressSetRepo.sol";
import {FacetSetLayout, IDiamondLoupe} from "daosys/introspection/erc2535/mutable/libs/FacetSetLayout.sol";
import {IDiamondLoupe} from "daosys/introspection/erc2535/interfaces/IDiamondLoupe.sol";

    // TODO Implement Faceet replacement,
    // TODO Implement Faceet removal,
library MutableERC2535Layout {

    using AddressSetRepo for AddressSet;
    using FacetSetLayout for FacetSetLayout.Struct;

  struct Struct {
    FacetSetLayout.Struct facets;
    mapping(address facet => bytes4[] functionSelectors) facetFunctionSelectors;
    AddressSet facetAddresses;
    mapping(bytes4 functionSelector => address facet) facetAddress;
  }

  function _storeFacet(
    MutableERC2535Layout.Struct storage layout,
    IDiamondLoupe.Facet memory facet
  ) internal {
    layout.facets._add(facet);
    layout.facetFunctionSelectors[facet.facetAddress] = facet.functionSelectors;
    layout.facetAddresses._add(facet.facetAddress);
  }

  function _removeFacet(
    MutableERC2535Layout.Struct storage layout,
    IDiamondLoupe.Facet memory facet
  ) internal {
    layout.facets._remove(facet.facetAddress);
    // Does not actually delete values, just unmaps storage pointer.
    delete layout.facetFunctionSelectors[facet.facetAddress];
    layout.facetAddresses._remove(facet.facetAddress);
  }

  function _loadFacets(
    MutableERC2535Layout.Struct storage layout
  ) internal view returns(IDiamondLoupe.Facet[] memory allFacets) {
    allFacets = layout.facets._setAsArray();
  }

  function _loadFacetFunctionSelectors(
    MutableERC2535Layout.Struct storage layout,
    address facetAddress
  ) internal view returns(bytes4[] memory facetFunctionSelectors) {
    facetFunctionSelectors = layout.facetFunctionSelectors[facetAddress];
  }

  function _loadFacetAddresses(
    MutableERC2535Layout.Struct storage layout
  ) internal view returns(address[] memory facetAddresses) {
    facetAddresses = layout.facetAddresses._asArray();
  }

  function _storeFacetAddress(
    MutableERC2535Layout.Struct storage layout,
    bytes4 functionSelector,
    address facetAddress
  ) internal {
    layout.facetAddress[functionSelector] = facetAddress;
  }

  function _loadFacetAddress(
    MutableERC2535Layout.Struct storage layout,
    bytes4 functionSelector
  ) internal view returns(address facetAddress) {
    facetAddress = layout.facetAddress[functionSelector];
  }

}