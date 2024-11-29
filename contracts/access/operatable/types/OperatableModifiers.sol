// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/operatable/types/OperatableStorage.sol";

/**
 * @title OperatableModifiers - Inheritable modifiers for Operatable validations.
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
        if(
            // Global approval is acceptable.
            !_isOperator(query)
            // Function level approval is acceptable.
            && !_operatable().isOperatorFor[msg.sig][query]
        ) {
            // Revert IF neither global NOR function level approved.
            revert IOperatable.NotOperator(query);
        }
        _;
    }
    

    /**
     * @param query Revert if query is NOT authorized as an operator OR ownership has been renounced.
     */
    modifier onlyOperatorOrRenounced(address query) {
        if(
            // No Owner authorizes ALL callers.
            _ownable().owner != address(0)
            // Global approval is acceptable.
            && !_isOperator(query)
            // Function level approval is acceptable.
            && !_operatable().isOperatorFor[msg.sig][query]
        ) {
            // Revert IF neither global NOR function level approved AND IS owned.
            revert IOperatable.NotOperator(query);
        }
        _;
    }

    /**
     * @param query Revert if query is NOT authorized as an operator NOR owner.
     */
    modifier onlyOwnerOrOperator(address query) {
        if(
            // Global approval is acceptable.
            !_isOperator(query)
            // Function level approval is acceptable.
            && !_operatable().isOperatorFor[msg.sig][query]
            // Owner status is acceptable.
            && !_isOwner(query)
        ) {
            // Revert IF neither global NOR function level approved NOR owner.
            revert IOperatable.NotOperator(query);
        }
        _;
    }

    /**
     * @param query Revert if query is NOT authorized as an operator OR owner OR ownership has been renounced.
     */
    modifier onlyOwnerOrOperatorOrRenounced(address query) {
        if(
            // No Owner authorizes ALL callers.
            _ownable().owner != address(0)
            // Global approval is acceptable.
            && !_isOperator(query)
            // Function level approval is acceptable.
            && !_operatable().isOperatorFor[msg.sig][query]
            // Owner status is acceptable.
            && !_isOwner(query)
        ) {
            // Revert IF neither global NOR function level approved AND IS owned.
            revert IOperatable.NotOperator(query);
        }
        _;
    }

}