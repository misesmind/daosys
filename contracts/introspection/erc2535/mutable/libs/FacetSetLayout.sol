// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {IDiamondLoupe} from "daosys/introspection/erc2535/interfaces/IDiamondLoupe.sol";

library FacetSetLayout {

  struct Struct {
    IDiamondLoupe.Facet[] values;
    mapping(address => uint256) indexes;
  }

  function _contains(
    FacetSetLayout.Struct storage set,
    address value
  ) internal view returns (bool) {
    return set.indexes[value] != 0;
  }

  // Writen to be idempotent.
  function _add(
    FacetSetLayout.Struct storage set,
    IDiamondLoupe.Facet memory value
  ) internal returns (bool) {
    if (!_contains(set, value.facetAddress)) {
      set.values.push(value);
      set.indexes[value.facetAddress] = set.values.length;
    } 
    return true;
  }

  // Writen to be idempotent.
  function _remove(
    FacetSetLayout.Struct storage set,
    address value
  ) internal returns (bool) {
    uint valueIndex = set.indexes[value];

    if (valueIndex != 0) {
      uint index = valueIndex - 1;
      IDiamondLoupe.Facet memory last = set.values[set.values.length - 1];

      // move last value to now-vacant index

      set.values[index] = last;
      set.indexes[last.facetAddress] = index + 1;

      // clear last index

      set.values.pop();
      delete set.indexes[value];

    }

    return true;
  }

  function _setAsArray(
    FacetSetLayout.Struct storage set
  ) internal view returns (IDiamondLoupe.Facet[] storage rawSet) {
    rawSet = set.values;
  }

  function _asArray(
    FacetSetLayout.Struct storage set
  ) internal view returns (IDiamondLoupe.Facet[] storage rawSet) {
    rawSet = set.values;
  }

}