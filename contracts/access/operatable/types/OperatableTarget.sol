// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/operatable/types/OperatableModifiers.sol";
import "daosys/access/ownable/types/OwnableModifiers.sol";

/**
 * @title OperatableTarget - Exposes IOperatable functions.
 */
contract OperatableTarget
is
OwnableModifiers,
OperatableModifiers,
// OwnableTarget,
IOperatable
{

    /**
     * @inheritdoc IOperatable
     */
    function isOperator(address query)
    public view virtual returns(bool) {
        return _isOperator(query);
    }

    function isOperatorFor(bytes4 func, address query)
    public view returns(bool) {
        return _operatable().isOperatoFor[func][query];
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

    function setOperatorFor(bytes4 func, address newOperator, bool approval)
    public 
    onlyOwner(msg.sender)
    returns(bool) {
        _operatable().isOperatoFor[func][newOperator] = approval;
        return true;
    }

}