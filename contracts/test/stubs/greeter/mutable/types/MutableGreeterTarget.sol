// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "contracts/test/stubs/greeter/mutable/interfaces/IMutableGreeter.sol";

struct MutableGreeterLayout {
    string message;
}

library MutableGreeterRepo {

    using MutableGreeterRepo for MutableGreeterLayout;

    // tag::slot[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     */
    function slot(
        MutableGreeterLayout storage table
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
        MutableGreeterLayout storage table
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
    ) external pure returns(MutableGreeterLayout storage layout_) {
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
    ) internal pure returns(MutableGreeterLayout storage layout_) {
        assembly{layout_.slot := slot_}
    }
    // end::_layout[]

}

abstract contract MutableGreeterStorage {

    /* ------------------------------ LIBRARIES ----------------------------- */

    using MutableGreeterRepo for MutableGreeterLayout;

    /* ------------------------- EMBEDDED LIBRARIES ------------------------- */

    // TODO Replace with address of deployed library.
    // Normally handled by usage for storage slot.
    // Included to facilitate automated audits.
    address constant MUTABLE_GREETER_LAYOUT_ID = address(uint160(uint256(keccak256(type(MutableGreeterRepo).creationCode))));

    /* ---------------------------------------------------------------------- */
    /*                                 STORAGE                                */
    /* ---------------------------------------------------------------------- */

    /* -------------------------- STORAGE CONSTANTS ------------------------- */
  
    // Defines the default offset applied to all provided storage ranges for use when operating on a struct instance.
    // Subtract 1 from hashed value to ensure future usage of relevant library address.
    bytes32 constant internal MUTABLE_GREETER_STORAGE_RANGE_OFFSET = bytes32(uint256(keccak256(abi.encode(MUTABLE_GREETER_LAYOUT_ID))) - 1);

    // The default storage range to use with the Layout libraries consumed by this library.
    // Service libraries are expected to coordinate operations in relation to a interface between other Services and Repos.
    bytes32 internal constant MUTABLE_GREETER_STORAGE_RANGE = type(IMutableGreeter).interfaceId;
    bytes32 internal constant MUTABLE_GREETER_STORAGE_SLOT = MUTABLE_GREETER_STORAGE_RANGE ^ MUTABLE_GREETER_STORAGE_RANGE_OFFSET;

    /**
     * @dev internal hook for the default storage range used by this library.
     * @dev Other services will use their default storage range to ensure consistent storage usage.
     * @return The default storage range used with repos.
     */
    function _greeter()
    internal pure virtual returns(MutableGreeterLayout storage) {
        return MutableGreeterRepo._layout(MUTABLE_GREETER_STORAGE_SLOT);
    }

    function _initGreeter(
        string memory msg_
    ) internal {
        _greeter().message = msg_;
    }

}

contract MutableGreeterTarget
is
MutableGreeterStorage
,IMutableGreeter
{

    function getMessage()
    public view returns(string memory) {
        return _greeter().message;
    }

    function setMessage(
        string memory msg_
    ) public returns(bool) {
        _greeter().message = msg_;
        return true;
    }

}