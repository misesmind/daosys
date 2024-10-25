// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {
    IERC20Errors,
    IERC20,
    ERC20Storage,
    ERC20Target,
    ERC20MintableTarget
} from "./ERC20MintableTarget.sol";
import {OperatableTarget} from "contracts/access/operatable/types/OperatableTarget.sol";
import {
    IERC20OperatableMintable
} from "contracts/tokens/erc20/interfaces/IERC20OperatableMintable.sol";

contract ERC20OpertableMintableTarget is ERC20MintableTarget, OperatableTarget, IERC20OperatableMintable {

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