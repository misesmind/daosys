// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

struct Bytes4Set {
    // 1-indexed to allow 0 to signify nonexistence
    mapping( bytes4 => uint256 ) indexes;
    bytes4[] values;
}

library Bytes4SetRepo {

    function _index(
        Bytes4Set storage set,
        uint index
    ) internal view returns (bytes4 value) {
        require(set.values.length > index, "LayoutSet: index out of bounds");
        value = set.values[index];
    }

    function _contains(
        Bytes4Set storage set,
        bytes4 value
    ) internal view returns (bool success)
    {
        return set.indexes[value] != 0;
    }

    function _indexOf(
        Bytes4Set storage set,
        bytes4 value
    ) internal view returns (uint index) {
        unchecked {
            index = set.indexes[value] - 1;
        }
    }

    function _length(
        Bytes4Set storage set
    ) internal view returns (uint length) {
        length = set.values.length;
    }

    function _add(
        Bytes4Set storage set,
        bytes4[] memory values
    ) internal returns (bool success) {
        for(uint256 iteration = 0; iteration < values.length; iteration++) {
            _add(set, values[iteration]);
        }
        return true;
    }

    function _addExclusive(
        Bytes4Set storage set,
        bytes4[] memory values
    ) internal returns (bool success) {
        for(uint256 iteration = 0; iteration < values.length; iteration++) {
            success = _addExclusive(set, values[iteration]);
            require(success == true, "Bytes4Set: value already present.");
        }
    }

    function _add(
        Bytes4Set storage set,
        bytes4 value
    ) internal returns (bool success) {
        if (!_contains(set, value)) {
            set.values.push(value);
            set.indexes[value] = set.values.length;
        }
        return true;
    }

    function _addExclusive(
        Bytes4Set storage set,
        bytes4 value
    ) internal returns (bool success) {
        if (!_contains(set, value)) {
            set.values.push(value);
            set.indexes[value] = set.values.length;
            return true;
        }
        return false;
    }

    function _remove(
        Bytes4Set storage set,
        bytes4 value
    ) internal returns (bool success) {
        uint valueIndex = set.indexes[value];

        if (valueIndex != 0) {
            uint index = valueIndex - 1;
            bytes4 last = set.values[set.values.length - 1];

            // move last value to now-vacant index

            set.values[index] = last;
            set.indexes[last] = index + 1;

            // clear last index

            set.values.pop();
            delete set.indexes[value];
        }
        return true;
    }

    function _remove(
        Bytes4Set storage set,
        bytes4[] memory values
    ) internal returns (bool success) {
        for(uint256 iteration = 0; iteration < values.length; iteration++) {
            _remove(set, values[iteration]);
        }
        return true;
    }

    function _asArray(
        Bytes4Set storage set
    ) internal view returns (bytes4[] storage rawSet) {
        rawSet = set.values;
    }

    function _wipeSet(
        Bytes4Set storage set
    ) internal returns (bool success) {
        for(uint256 cursor = 0; cursor < set.values.length; cursor++) {
        delete set.indexes[set.values[cursor]];
        // TODO Refactor to pop entries off array to reduce size.
        }
        return true;
    }

    function _lastDestruct(
        Bytes4Set storage set
    ) internal returns(bytes4 lastValue) {
        lastValue = set.values[set.values.length - 1];
        delete set.indexes[lastValue];
        set.values.pop();
    }

}