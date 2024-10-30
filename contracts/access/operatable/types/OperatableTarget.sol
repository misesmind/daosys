// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/operatable/types/OperatableModifiers.sol";

/**
 * @title OperatableTarget - Exposes IOperatable functions.
 */
contract OperatableTarget
is
OperatableModifiers,
OwnableTarget,
IOperatable
{

    /**
     * @inheritdoc IOperatable
     */
    function isOperator(address query)
    public view virtual returns(bool) {
        return _isOperator(query);
    }

    /**
     * @notice Restricted to owner.
     * @inheritdoc IOperatable
     */
    function setOperator(
        address operator,
        bool status
    ) public virtual
    onlyOwner(msg.sender)
    returns(bool) {
        _isOperator(operator, status);
        return true;
    }

}