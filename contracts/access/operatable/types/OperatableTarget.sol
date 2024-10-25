// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "../libs/OperatableRepo.sol";
import {IOperatable} from "../interface/IOperatable.sol";
import {
    OwnableStorage,
    OwnableTarget
} from "../../ownable/types/OwnableTarget.sol";

struct OperatableLayout {
    mapping(address => bool) isOperator;
}

library OperatableRepo {

    // tag::slot[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     * @custom:sig slot(ERC20Struct storage)
     * @custom:selector 0x5bbea693
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
     * @custom:sig layout(bytes32)
     * @custom:selector 0x81366cef
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

abstract contract OperatableStorage is OwnableStorage {

    using OperatableRepo for OperatableLayout;

    address constant OperatableRepo_ID = address(uint160(uint256(keccak256(type(OperatableRepo).creationCode))));
    bytes32 constant internal OperatableRepo_STORAGE_RANGE_OFFSET = bytes32(uint256(keccak256(abi.encode(OperatableRepo_ID))) - 1);
    bytes32 internal constant OperatableRepo_STORAGE_RANGE = type(IOperatable).interfaceId;
    bytes32 internal constant OperatableRepo_STORAGE_SLOT = OperatableRepo_STORAGE_RANGE ^ OperatableRepo_STORAGE_RANGE_OFFSET;

    function _operatable()
    internal pure virtual returns(OperatableLayout storage) {
        return OperatableRepo._layout(OperatableRepo_STORAGE_SLOT);
    }

}

contract OperatableTarget
is
OperatableStorage,
OwnableTarget,
IOperatable
{

    modifier onlyOperator(address query) {
        require(isOperator(query), "Operator: caller is not an operator");
        _;
    }

    modifier onlyOwnerOrOperator(address query) {
        require(isOperator(query) || _isOwner(query), "Operator: caller is not owenr or an operator");
        _;
    }

    function isOperator(address query) public view virtual returns(bool) {
        return _operatable().isOperator[query];
    }

    function _isOperator(address query, bool approval) internal {
        _operatable().isOperator[query] = approval;
    }

    function setOperator(
        address operator,
        bool status
    ) public virtual
    // onlyOwnerOrOperator(msg.sender)
    onlyOwner(msg.sender)
    returns(bool) {
        // require(msg.sender == minter, "Operator: caller is not the minter");
        // operators[operator] = status;
        _isOperator(operator, status);
        return true;
    }

}