// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import {MutableERC165Layout, MutableERC165Repo} from "daosys/introspection/erc165/mutable/libs/MutableERC165Repo.sol";
import {IERC165} from "daosys/introspection/erc165/interfaces/IERC165.sol";
import {ERC165Utils} from "daosys/introspection/erc165/libs/ERC165Utils.sol";

struct MutableERC165Layout {
    mapping(bytes4 interfaceId => bool isSupported) isSupportedInterface;
}

/**
 * @title MutableERC165Repo - Repository library for ERC165 relevant state.
 * @author cyotee doge <doge.cyotee>
 */
library MutableERC165Repo {

    // tag::slot[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     */
    function slot(
        MutableERC165Layout storage table
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
        MutableERC165Layout storage table
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
    ) external pure returns(MutableERC165Layout storage layout_) {
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
    ) internal pure returns(MutableERC165Layout storage layout_) {
        assembly{layout_.slot := slot_}
    }
    // end::_layout[]

}

/**
 * @title MutableERC165Storage - Inheritable 
 */
abstract contract MutableERC165Storage {

    using ERC165Utils for bytes4[];
    using MutableERC165Repo for MutableERC165Layout;

    address constant MutableERC165Repo_ID =
        // address(uint160(uint256(keccak256(type(MutableERC165Repo).creationCode))));
        address(MutableERC165Repo);
    bytes32 constant internal MutableERC165Repo_STORAGE_RANGE_OFFSET =
        bytes32(uint256(keccak256(abi.encode(MutableERC165Repo_ID))) - 1);
    bytes32 internal constant MutableERC165Repo_STORAGE_RANGE =
        type(IERC165).interfaceId;
    bytes32 internal constant MutableERC165Repo_STORAGE_SLOT =
        MutableERC165Repo_STORAGE_RANGE ^ MutableERC165Repo_STORAGE_RANGE_OFFSET;
    
    function _erc165()
    internal pure virtual returns(MutableERC165Layout storage) {
        return MutableERC165Repo._layout(MutableERC165Repo_STORAGE_SLOT);
    }

    function _initERC165(
        bytes4[] memory supportedInterfaces_
    ) internal {
        for(uint256 cursor = 0; cursor < supportedInterfaces_.length; cursor ++) {
            _erc165().isSupportedInterface[supportedInterfaces_[cursor]] = true;
        }
    }

}