// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/operatable/types/OperatableStorage.sol";

/**
 * @title OperatableModifiers - Inheritable modifiers for Operatorable validations.
 * @author cyotee doge <doge.cyotee>
 */
contract OperatableModifiers
is
OperatableStorage
{

    /**
     * @param query Revert if query is NOT authorized as an operator.
     */
    modifier onlyOperator(address query) {
        if(!_isOperator(query)) {
            revert IOperatable.NotOperator(query);
        }
        _;
    }

    /**
     * @param query Revert if query is NOT authroized as an operator OR ownership has been renounced.
     */
    modifier onlyOperatorOrRenounced(address query) {
        if(
            !_isOperator(query)
            && _ownable().owner != address(0)
        ) {
            revert IOperatable.NotOperator(query);
        }
        _;
    }

    /**
     * @param query Revert if query is NOT authroized as an operator OR not owner.
     */
    modifier onlyOwnerOrOperator(address query) {
        if(
            !_isOperator(query)
            && !_isOwner(query)
        ) {
            revert IOperatable.NotOperator(query);
        }
        _;
    }

    /**
     * @param query Revert if query is NOT authroized as an operator OR owner OR ownership has been renounced.
     */
    modifier onlyOwnerOrOperatorOrRenounced(address query) {
        if(
            !_isOperator(query)
            && !_isOwner(query)
            && _ownable().owner != address(0)
        ) {
            revert IOperatable.NotOperator(query);
        }
        _;
    }

}