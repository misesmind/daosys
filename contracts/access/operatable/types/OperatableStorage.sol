// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/ownable/types/OwnableTarget.sol";
import "daosys/access/operatable/interface/IOperatable.sol";
import "daosys/access/operatable/libs/OperatableRepo.sol";

/**
 * @title OperatableStorage - Inheritable storage logic for IOperatable.
 * @author cyotee doge <doge.cyotee>
 * @dev Operator is defined as an address authorized to call functions.
 * @dev Operator MAY be GLOBAL AND/OR function level.
 * @dev Can be improved with RBAC implementation from experimental repo.
 * @dev Defines CRUD operations to promote consistency with validation logic.
 */
abstract contract OperatableStorage is OwnableStorage {

    using OperatableRepo for OperatableLayout;

    // Repositories are deployed to "declare" a "datatype" for use by future proxies.
    address constant OperatableRepo_ID = address(OperatableRepo);
    // Hash the Repository address derive an offset from the "service" storage slot range.
    // Offset hash value to obfuscate original value.
    // Expectation is to make it harder to obfuscate storage access in an upgrade.
    bytes32 constant internal OperatableRepo_STORAGE_RANGE_OFFSET = bytes32(uint256(keccak256(abi.encode(OperatableRepo_ID))) - 1);
    // Declare the "range" of storage slots "reserved" for a "service" exposing an interface.
    bytes32 internal constant OperatableRepo_STORAGE_RANGE = type(IOperatable).interfaceId;
    // Calculate the actual first slot to use with the repository when exposing a "service".
    bytes32 internal constant OperatableRepo_STORAGE_SLOT = OperatableRepo_STORAGE_RANGE ^ OperatableRepo_STORAGE_RANGE_OFFSET;

    /**
     * @return Diamond storage struct bound to the declared "service" slot.
     */
    function _operatable()
    internal pure virtual returns(OperatableLayout storage) {
        return OperatableRepo._layout(OperatableRepo_STORAGE_SLOT);
    }

    /**
     * @param query Address for which to query operator authorization.
     * @return Boolean indicating authorization as an operator.
     */
    function _isOperator(address query)
    internal view virtual returns(bool) {
        return _operatable().isOperator[query];
    }

    /**
     * @param query Subject of operator authorization change.
     * @param approval Desired authorization status.
     */
    function _isOperator(
        address query,
        bool approval
    ) internal {
        _operatable().isOperator[query] = approval;
    }

    /**
     * @param func Function selector for which to query authorization of `newOperator`.
     * @param query Address for which to query operator authorization.
     * @return Boolean indicating authorization as an operator.
     */
    function _isOperatorFor(
        bytes4 func,
        address query
    ) internal view virtual returns(bool) {
        return _operatable().isOperatorFor[func][query];
    }

    /**
     * @param func Function selector for which to update authorization of `newOperator`.
     * @param newOperator Account for which to update authorization to call `func`.
     * @param approval Call authorization change.
     */
    function _isOperatorFor(
        bytes4 func,
        address newOperator,
        bool approval
    ) internal {
        _operatable().isOperatorFor[func][newOperator] = approval;
    }

}