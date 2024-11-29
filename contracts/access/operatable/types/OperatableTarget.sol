// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/operatable/types/OperatableStorage.sol";
import "daosys/access/ownable/types/OwnableModifiers.sol";

/**
 * @title OperatableTarget - Exposes IOperatable functions.
 * @author cyotee doge <doge.cyotee>
 * @notice Deliberately DOES NOT expose IOwnable.
 * @dev Uses storage CRUD operations to ensure consistency with validations.
 */
contract OperatableTarget
is
// Some functions are restricted to Owner.
OwnableModifiers
// Uses Operatable diamond storage.
,OperatableStorage
// Exposes IOperatable interface
,IOperatable
{

    /**
     * @inheritdoc IOperatable
     */
    function isOperator(address query)
    public view virtual returns(bool) {
        return _isOperator(query);
    }

    /**
     * @inheritdoc IOperatable
     */
    function isOperatorFor(
        bytes4 func,
        address query
    ) public view returns(bool) {
        return _isOperatorFor(func, query);
    }

    /**
     * @notice Restricted to owner.
     * @inheritdoc IOperatable
     */
    function setOperator(
        address operator,
        bool status
    ) public virtual
    // Restrict to ONLY calls from Owner.
    onlyOwner(msg.sender)
    returns(bool) {
        _isOperator(operator, status);
        return true;
    }

    /**
     * @notice Restricted to owner.
     * @inheritdoc IOperatable
     */
    function setOperatorFor(
        bytes4 func,
        address newOperator,
        bool approval
    ) public 
    // Restrict to ONLY calls from Owner.
    onlyOwner(msg.sender)
    returns(bool) {
        _isOperatorFor(func, newOperator, approval);
        return true;
    }

}