// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

/* ---------------------------------- ERC20 --------------------------------- */

import {IERC20} from "daosys/tokens/erc20/interfaces/IERC20.sol";

// tag::ERC20Layout[]
// Named with Struct suffix to ensure no namespace collisions.
struct ERC20Layout {
    string name;
    string symbol;
    uint8 decimals;
    uint256 totalSupply;
    mapping(address account => uint256 balance) balanceOf;
    mapping(address account => mapping(address spender => uint256 approval)) allowances;
}
// end::ERC20Layout[]

// tag::ERC20Repo[]
/**
 * @title ERC20Repo Library to usage the related Struct as a storage layout.
 * @author cyotee dgoe <cyotee@syscoin.org>
 * @notice Simplifies Assembly operations upon the related Struct.
 */
library ERC20Repo {

    using ERC20Repo for ERC20Layout;

    // tag::slot[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     * @custom:sig slot(ERC20Layout storage)
     * @custom:selector 0x5bbea693
     */
    function slot(
        ERC20Layout storage table
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
        ERC20Layout storage table
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
    ) external pure returns(ERC20Layout storage layout_) {
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
    ) internal pure returns(ERC20Layout storage layout_) {
        assembly{layout_.slot := slot_}
    }
    // end::_layout[]

}
// end::ERC20Repo[]