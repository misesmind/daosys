// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title Bytes32SetLayout - Struct and atomic operations for a set of 32 byte values
 * @author mises mind <misesmind@proton.me>
 */
library Bytes32SetLayout {

    using Bytes32SetLayout for Bytes32SetLayout.Struct;
  
    struct Struct {
        // 1-indexed to allow 0 to signify nonexistence
        mapping( bytes32 => uint256 ) indexes;
        bytes32[] values;
    }

    /**
     * @dev Will rrevert is provided index is out of bounds.
     * @param set The sotrage struct upon which this function will operate.
     * @param index The index of the value to be loaded from storage.
     * @return value The value from the set at the provided index.
     */
    function _index(
        Bytes32SetLayout.Struct storage set,
        uint index
    ) internal view returns (bytes32 value) {
        require(set.values.length > index, "Bytes32Set: index out of bounds");
        value = set.values[index];
    }

    function _contains(
        Bytes32SetLayout.Struct storage set,
    bytes32 value
  ) internal view returns (bool success)
  {
    success = set.indexes[value] != 0;
  }

  function _indexOf(
    Bytes32SetLayout.Struct storage set,
    bytes32 value
  ) internal view returns (uint index) {
    unchecked {
      index = set.indexes[value] - 1;
    }
  }

  function _length(
    Bytes32SetLayout.Struct storage set
  ) internal view returns (uint length) {
    length = set.values.length;
  }

  function _add(
    Bytes32SetLayout.Struct storage set,
    bytes32 value
  ) internal returns (bool success) {
    if (!_contains(set, value)) {
      set.values.push(value);
      set.indexes[value] = set.values.length;
    }
    success = true;
  }

  function _addExclusive(
    Bytes32SetLayout.Struct storage set,
    bytes32 value
  ) internal returns (bool success) {
    if (!_contains(set, value)) {
      set.values.push(value);
      set.indexes[value] = set.values.length;
      return true;
    }
    return false;
  }

  function _add(
    Bytes32SetLayout.Struct storage set,
    bytes32[] memory values
  ) internal returns (bool success) {
    for(uint256 iteration = 0; iteration < values.length; iteration++) {
      _add(set, values[iteration]);
    }
    success = true;
  }

  function _addExclusive(
    Bytes32SetLayout.Struct storage set,
    bytes32[] memory values
  ) internal returns (bool success) {
    for(uint256 iteration = 0; iteration < values.length; iteration++) {
      success = _addExclusive(set, values[iteration]);
      require(success == true, "AddressSet: value already present.");
    }
  }

  function _remove(
    Bytes32SetLayout.Struct storage set,
    bytes32 value
  ) internal returns (bool success) {
    uint valueIndex = set.indexes[value];

    if (valueIndex != 0) {
      uint index = valueIndex - 1;
      bytes32 last = set.values[set.values.length - 1];

      // move last value to now-vacant index

      set.values[index] = last;
      set.indexes[last] = index + 1;

      // clear last index

      set.values.pop();
      delete set.indexes[value];

    }
    success = true;
  }

  function _remove(
    Bytes32SetLayout.Struct storage set,
    bytes32[] memory values
  ) internal returns (bool success) {
    for(uint256 iteration = 0; iteration < values.length; iteration++) {
      _remove(set, values[iteration]);
    }
    success = true;
  }

  function _values(
    Bytes32SetLayout.Struct storage set
  ) internal view returns (bytes32[] storage rawSet) {
    rawSet = set.values;
  }

}