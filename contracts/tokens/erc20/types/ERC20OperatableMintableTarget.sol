// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {
    IERC20Errors,
    IERC20,
    ERC20Storage,
    ERC20Target,
    IERC20Mintable,
    ERC20MintableTarget
} from "daosys/tokens/erc20/types/ERC20MintableTarget.sol";
import {
    IOwnable,
    IOperatable,
    OperatableTarget
} from "daosys/access/operatable/types/OperatableTarget.sol";
import "daosys/access/operatable/types/OperatableModifiers.sol";
import {
    IERC20OperatableMintable
} from "daosys/tokens/erc20/interfaces/IERC20OperatableMintable.sol";

contract ERC20OperatableMintableTarget
is
ERC20MintableTarget
,OperatableModifiers
,OperatableTarget
,IERC20OperatableMintable
{

    function mint(
        uint256 amount,
        address to
    ) external payable virtual override(IERC20OperatableMintable, ERC20MintableTarget) onlyOperator(msg.sender) returns(uint256) {
        _mint(amount, to);
        return amount;
    }

    function burn(
        uint256 amount,
        address to
    ) external virtual override(IERC20OperatableMintable, ERC20MintableTarget) onlyOperator(msg.sender) returns(uint256) {
        _burn(amount, to);
        return amount;
    }

    function isOperator(address query) public view override(IERC20OperatableMintable, OperatableTarget) returns(bool) {
        return _operatable().isOperator[query];
    }

    function setOperator(
        address operator,
        bool status
    ) public virtual override(IERC20OperatableMintable, OperatableTarget) returns(bool) {
        // require(msg.sender == minter, "Operator: caller is not the minter");
        // operators[operator] = status;
        OperatableTarget.setOperator(operator, status);
        return true;
    }

}