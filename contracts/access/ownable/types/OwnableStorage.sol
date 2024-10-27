// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

// import "../libs/OwnableRepo.sol";
import {IOwnable} from "daosys/access/ownable/interfaces/IOwnable.sol";

struct OwnableLayout {
    address owner;
    address proposedOwner;
}

library OwnableRepo {

    // tag::slot(OwnableLayout storage)[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     */
    function slot(
        OwnableLayout storage table
    ) external pure returns(bytes32 slot_) {
        return _slot(table);
    }
    // end::slot(OwnableLayout storage)[]

    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     */
    function _slot(
        OwnableLayout storage table
    ) internal pure returns(bytes32 slot_) {
        assembly{slot_ := table.slot}
    }

    // tag::layout(bytes32)[]
    /**
     * @dev "Binds" this struct to a storage slot.
     * @param slot_ The first slot to use in the range of slots used by the struct.
     * @return layout_ A struct from a Layout library bound to the provided slot.
     */
    function layout(
        bytes32 slot_
    ) external pure returns(OwnableLayout storage layout_) {
        return _layout(slot_);
    }
    // end::layout(bytes32)[]

    /**
     * @dev "Binds" a struct to a storage slot.
     * @param storageRange The first slot to use in the range of slots used by the struct.
     * @return layout_ A struct from a Layout library bound to the provided slot.
     */
    function _layout(
        bytes32 storageRange
    ) internal pure returns(OwnableLayout storage layout_) {
        assembly{layout_.slot := storageRange}
    }

}

abstract contract OwnableStorage {

    /* ------------------------------ LIBRARIES ----------------------------- */

    using OwnableRepo for OwnableLayout;

    /* ------------------------- EMBEDDED LIBRARIES ------------------------- */

    // TODO Replace with address of deployed library.
    // Normally handled by usage for storage slot.
    // Included to facilitate automated audits.
    address constant OwnableRepo_ID = address(uint160(uint256(keccak256(type(OwnableRepo).creationCode))));

    /* ---------------------------------------------------------------------- */
    /*                                 STORAGE                                */
    /* ---------------------------------------------------------------------- */

    /* -------------------------- STORAGE CONSTANTS ------------------------- */
  
    // Defines the default offset applied to all provided storage ranges for use when operating on a struct instance.
    // Subtract 1 from hashed value to ensure future usage of relevant library address.
    bytes32 constant internal OwnableRepo_STORAGE_RANGE_OFFSET = bytes32(uint256(keccak256(abi.encode(OwnableRepo_ID))) - 1);

    // The default storage range to use with the Repo libraries consumed by this library.
    // Service libraries are expected to coordinate operations in relation to a interface between other Services and Repos.
    bytes32 internal constant OwnableRepo_STORAGE_RANGE = type(IOwnable).interfaceId;
    bytes32 internal constant OwnableRepo_STORAGE_SLOT = OwnableRepo_STORAGE_RANGE ^ OwnableRepo_STORAGE_RANGE_OFFSET;

    modifier onlyOwner(address challenger) {
        _ifNotOwner(challenger);
        _;
    }

    modifier onlyProposedOwner(address challenger) {
        _ifNotProposedOwner(challenger);
        _;
    }

    function _initOwner(address newOwner) internal {
        _ownable().owner = newOwner;
        emit IOwnable.OwnershipTransfered(
            address(0),
            newOwner
        );
    }

    // tag::_ownable()[]
    /**
     * @dev internal hook for the default storage range used by this library.
     * @dev Other services will use their default storage range to ensure consistant storage usage.
     * @return The default storage range used with repos.
     */
    function _ownable()
    internal pure virtual returns(OwnableLayout storage) {
        return OwnableRepo._layout(OwnableRepo_STORAGE_SLOT);
    }
    // end::_ownable()[]

    function _owner() internal view returns(address) {
        return _ownable().owner;
    }

    function _isOwner(address challenger) internal view returns(bool) {
        return challenger == _owner();
    }

    function _ifNotOwner(address challenger) internal view {
        if(!_isOwner(challenger)) {
            revert IOwnable.NotOwner(challenger);
        }
    }

    function _proposedOwner() internal view returns(address) {
        return _ownable().proposedOwner;
    }

    function _isProposedOwner(address challenger) internal view returns(bool) {
        return challenger == _proposedOwner();
    }

    function _ifNotProposedOwner(address challenger) internal view {
        if(!_isProposedOwner(challenger)) {
            revert IOwnable.NotProposed(challenger);
        }
    }

    function _transferOwnerShip(address proposedOwner_) internal returns(bool) {
        _ownable().proposedOwner = proposedOwner_;
        emit IOwnable.TransferProposed(proposedOwner_);
        return true;
    }

    function _acceptOwnership() internal returns(bool) {
        address prevOwner = _ownable().owner;
        address newOwner = _ownable().proposedOwner;
        _ownable().owner = newOwner;
        _ownable().proposedOwner = address(0);
        emit IOwnable.OwnershipTransfered(prevOwner, newOwner);
        return true;
    }

    function _renounceOwnership() internal returns(bool) {
        require(_ownable().proposedOwner == address(0), "MUST NOT have proposed owner");
        address prevOwner = _ownable().owner;
        _ownable().owner = address(0);
        emit IOwnable.OwnershipTransfered(prevOwner, address(0));
        return true;
    }
    
}