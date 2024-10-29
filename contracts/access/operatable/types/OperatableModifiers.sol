// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/operatable/types/OperatableStorage.sol";

/**
 * @title OperatableModifiers - 
 */
contract OperatableModifiers
is
OperatableStorage
{

    modifier onlyOperator(address query) {
        require(_isOperator(query), "Operator: caller is not an operator");
        _;
    }

    modifier onlyOperatorOrRenounced(address query) {
        require(
            _isOperator(query)
            || _ownable().owner == address(0),
            "Operator: caller is not an operator"
        );
        _;
    }

    modifier onlyOwnerOrOperator(address query) {
        require(_isOperator(query) || _isOwner(query), "Operator: caller is not owenr or an operator");
        _;
    }

    modifier onlyOwnerOrOperatorOrRenounced(address query) {
        require(
            _isOperator(query)
            || _isOwner(query)
            || _ownable().owner == address(0), "Operator: caller is not owenr or an operator");
        _;
    }

}