// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Array} from "daosys/collections/arrays/Array.sol";

struct AddressSet {
    // 1-indexed to allow 0 to signify nonexistence
    mapping( address => uint256 ) indexes;
    // Values in set.
    address[] values;
}

/**
 * @title AddressSetRepo - Struct and atomic operations for a set of address values;
 * @author mises mind <misesmind@proton.me>
 * @dev Distinct from OpenZepplin to allow for operations upon an array of the same type.
 */
library AddressSetRepo {

    using Array for uint256;
    using AddressSetRepo for AddressSet;

    /* ------------------------- EMBEDDED LIBRARIES ------------------------- */

    // TODO Replace with address of deployed library.
    // Normally handled by usage as storage slot.
    // Included to facilitate automated audits.
    // address constant ARRAY_ID = address(Array);
    address constant ARRAY_ID = address(uint160(uint256(keccak256(type(Array).creationCode))));

    // tag::slot(AddressSet storage)[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     * @custom:sig slot(AddressSet storage)
     * @custom:selector 0x5bbea693
     */
    function slot(
        AddressSet storage table
    ) external pure returns(bytes32 slot_) {
        return _slot(table);
    }
    // end::slot(AddressSet storage)[]

    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     */
    function _slot(
        AddressSet storage table
    ) internal pure returns(bytes32 slot_) {
        assembly{slot_ := table.slot}
    }

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
    ) external pure returns(AddressSet storage layout_) {
        return _layout(slot_);
    }
    // end::layout[]

    /**
     * @dev "Binds" a struct to a storage slot.
     * @param storageRange The first slot to use in the range of slots used by the struct.
     * @return layout_ A struct from a Layout library bound to the provided slot.
     */
    function _layout(
        bytes32 storageRange
    ) internal pure returns(AddressSet storage layout_) {
        // storageRange ^= STORAGE_RANGE_OFFSET;
        assembly{layout_.slot := storageRange}
    }

    /**
     * @param set The storage pointer of the struct upon which this function should operate.
     * @param index The index of the value to retrieve.
     * @return value The value stored under the provided index.
     */
    function _index(
        AddressSet storage set,
        uint index
    ) internal view returns (address value) {
        require(set.values.length._isValidIndex(index));
        return set.values[index];
    }

    /**
     * @param set The storage pointer of the struct upon which this function should operate.
     * @param value The value of which to retrieve the index.
     * @return index The index of the value.
     */
    function _indexOf(
        AddressSet storage set,
        address value
    ) internal view returns (uint index) {
        unchecked {
            return set.indexes[value] - 1;
        }
    }

    /**
     * @param set The storage pointer of the struct upon which this function should operate.
     * @param value The value for which to check presence.
     * @return isPresent Boolean indicating presence of value in set.
     */
    function _contains(
        AddressSet storage set,
        address value
    ) internal view returns (bool isPresent) {
        return set.indexes[value] != 0;
    }

    /**
     * @param set The storage pointer of the struct upon which this function should operate.
     * @return length The "length", quantity of entries, of the provided set.
     */
    function _length(
        AddressSet storage set
    ) internal view returns (uint length) {
        return set.values.length;
    }

    /**
     * @dev Writen to be idempotent.
     * @dev Sets care about ensuring desired state.
     * @dev Desired state is for address to be present in set.
     * @dev If address is present, desired state has been achieved.
     * @dev When the state change was achieved is irrelevant.
     * @dev If presence prior to addition is relevant, encapsulating logic should check for presence.
     * @param set The storage pointer of the struct upon which this function should operate.
     * @param value The value to ensure is present in the provided set.
     * @return success Boolean indicating desired set state has been achieved.
     */
    function _add(
        AddressSet storage set,
        address value
    ) internal returns (bool success) {
        if (!_contains(set, value)) {
            set.values.push(value);
            set.indexes[value] = set.values.length;
        } 
        return true;
    }

    /**
     * @dev Idempotently adds an array of values to the provided set.
     * @param set The storage pointer of the struct upon which this function should operate.
     * @param values The array of values to ensure are present in the provided set.
     * @return success Boolean indicating desired set state has been achieved.
     */
    function _add(
        AddressSet storage set,
        address[] memory values
    ) internal returns (bool success) {
        for(uint256 iteration = 0; iteration < values.length; iteration++) {
            _add(set, values[iteration]);
        }
        return true;
    }

    function _addExclusive(
        AddressSet storage set,
        address value
    ) internal returns (bool success) {
        if (!_contains(set, value)) {
        set.values.push(value);
        set.indexes[value] = set.values.length;
        return true;
        }
        return false;
    }

    function _addExclusive(
        AddressSet storage set,
        address[] memory values
    ) internal returns (bool success) {
        for(uint256 iteration = 0; iteration < values.length; iteration++) {
        success = _addExclusive(set, values[iteration]);
        require(success == true, "AddressSet: value already present.");
        }
    }

    /**
     * @dev Written to be idempotent.
     * @dev Sets care about ensuring desired state.
     * @dev Desired state is for address to not be present in the set.
     * @dev If address is not present, desired state has been achieved.
     * @dev When the state change was achieved is irrelevant.
     * @dev If lack of presence prior to addition is relevant, encapsulating logic should check for lakc of presence.
     * @param set The storage pointer of the struct upon which this function should operate.
     * @param value The value to ensure is not present in the provided set.
     * @return success Boolean indicating desired set state has been achieved.
     */
    function _remove(
        AddressSet storage set,
        address value
    ) internal returns (bool success) {
        uint valueIndex = set.indexes[value];

        if (valueIndex != 0) {
            uint index = valueIndex - 1;
            address last = set.values[set.values.length - 1];

            // move last value to now-vacant index

            set.values[index] = last;
            set.indexes[last] = index + 1;

            // clear last index

            set.values.pop();
            delete set.indexes[value];

        }

        return true;
    }

    /**
     * @dev Idempotently removes an array of values to the provided set.
     * @param set The storage pointer of the struct upon which this function should operate.
     * @param values The array of values to ensure are not present in the provided set.
     * @return success Boolean indicating desired set state has been achieved.
     */
    function _remove(
        AddressSet storage set,
        address[] memory values
    ) internal returns (bool success) {
        for(uint256 iteration = 0; iteration < values.length; iteration++) {
            _remove(set, values[iteration]);
        }
        success = true;
    }

    /**
     * @dev Copies the set into memory as an array.
     * @param set The storage pointer of the struct upon which this function should operate.
     * @return array The members of the set copied to memory as an array.
     */
    function _asArray(
        AddressSet storage set
    ) internal view returns (address[] memory array) {
        array = set.values;
    }

    /**
     * @dev Provides the storage pointer os the underlying array of value.
     * @dev DO NOT alter values via this pointer.
     * @dev ONLY use to minimize memory usage when passing a reference internally for gas efficiency.
     * @param set The storage pointer of the struct upon which this function should operate.
     * @return values The members of the set copied to memory as an array.
     */
    function _values(
        AddressSet storage set
    ) internal view returns (address[] storage values) {
        values = set.values;
    }

    error InvalidPageSize(uint256 start, uint256 end);

    function _range(
        AddressSet storage set,
        uint256 start,
        uint256 end
    ) internal view returns(address[] memory array) {
        if(end < start) {
            revert InvalidPageSize(start, end);
        }
        uint256 setLen = set._length();
        require(setLen._isValidIndex(start));
        require(setLen._isValidIndex(end));
        uint256 returnLen = end - start + 1;
        array = new address[](returnLen);
        for(uint256 setCursor = start; setCursor <= end; setCursor++) {
            for(uint256 returnCursor = 0; returnCursor < returnLen; returnCursor++) {
                array[returnCursor] = set._index(setCursor);
            }
        }
    }

}