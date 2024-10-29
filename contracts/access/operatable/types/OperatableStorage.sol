// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/ownable/types/OwnableTarget.sol";
import "daosys/access/operatable/interface/IOperatable.sol";
import "daosys/access/operatable/libs/OperatableRepo.sol";

/**
 * @title OperatableStorage - Inheritable storage logic for IOperatable.
 * @author cyotee doge <doge.cyotee>
 * @dev Operator is defined as an address authorized to call bound functions.
 */
abstract contract OperatableStorage is OwnableStorage {

    using OperatableRepo for OperatableLayout;

    address constant OperatableRepo_ID = address(OperatableRepo);
    bytes32 constant internal OperatableRepo_STORAGE_RANGE_OFFSET = bytes32(uint256(keccak256(abi.encode(OperatableRepo_ID))) - 1);
    bytes32 internal constant OperatableRepo_STORAGE_RANGE = type(IOperatable).interfaceId;
    bytes32 internal constant OperatableRepo_STORAGE_SLOT = OperatableRepo_STORAGE_RANGE ^ OperatableRepo_STORAGE_RANGE_OFFSET;

    function _operatable()
    internal pure virtual returns(OperatableLayout storage) {
        return OperatableRepo._layout(OperatableRepo_STORAGE_SLOT);
    }

    /**
     * @param query Address for which to query operator authorization.
     * @return Boolean indicating aithorization as an operator.
     */
    function _isOperator(address query)
    internal view virtual returns(bool) {
        return _operatable().isOperator[query];
    }

    /**
     * @param query Subject of operator authorization change.
     * @param approval Desired authorization status.
     */
    function _isOperator(address query, bool approval) internal {
        _operatable().isOperator[query] = approval;
    }

}