// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

struct OperatableLayout {
    mapping(address => bool) isOperator;
    mapping(bytes4 func => mapping(address => bool)) isOperatorFor;
}

/**
 * @title OperatableRepo - Repository library for OperatableLayout;
 * @author cyotee doge <doge.cyotee>
 */
library OperatableRepo {

    // tag::slot[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     * @custom:func-sig slot(OperatableLayout storage)
     * @custom:func-sig-hash 0x048f4ff1
     */
    function slot(
        OperatableLayout storage table
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
        OperatableLayout storage table
    ) internal pure returns(bytes32 slot_) {
        assembly{slot_ := table.slot}
    }
    // end::_slot[]

    // tag::layout[]
    /**
     * @dev "Binds" this struct to a storage slot.
     * @param slot_ The first slot to use in the range of slots used by the struct.
     * @return layout_ A struct from a Layout library bound to the provided slot.
     * @custom:func-sig layout(bytes32)
     * @custom:func-sig-hash 0x81366cef
     */
    function layout(
        bytes32 slot_
    ) external pure returns(OperatableLayout storage layout_) {
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
    ) internal pure returns(OperatableLayout storage layout_) {
        assembly{layout_.slot := slot_}
    }
    // end::_layout[]

}