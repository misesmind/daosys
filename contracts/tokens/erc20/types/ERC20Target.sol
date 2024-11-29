// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    IERC20Errors,
    IERC20,
    ERC20Storage
} from "daosys/tokens/erc20/types/ERC20Storage.sol";

/**
 * @title ERC20Target - Proxy Logic target exposing ERC20 standard.
 * @author mises mind <misesmind@proton.me>
 * @dev Expects to be initialized.
 */
contract ERC20Target is ERC20Storage, IERC20 {

    // tag::name[]
    /**
     * @inheritdoc IERC20
     */
    function name()
    external view virtual returns (string memory) {
        return _name();
    }
    // end::name[]

    // tag::symbol[]
    /**
     * @inheritdoc IERC20
     */
    function symbol()
    external view virtual returns (string memory tokenSymbol) {
        tokenSymbol = _symbol();
    }
    // end::symbol[]

    // tag::decimals[]
    /**
     * @inheritdoc IERC20
     */
    function decimals()
    external view virtual returns (uint8) {
        return _decimals();
    }
    // end::decimals[]

    // tag::totalSupply[]
    /**
     * @inheritdoc IERC20
     */
    function totalSupply()
    external view virtual returns (uint256 supply) {
        supply = _totalSupply();
    }
    // end::totalSupply[]

    // tag::balanceOf[]
    /**
     * @inheritdoc IERC20
     */
    function balanceOf(
        address account
    ) external view virtual returns (uint256 balance) {
        return _balanceOf(account);
    }
    // end::balanceOf[]

    // tag::allowance[]
    /**
     * @inheritdoc IERC20
     */
    function allowance(
        address owner,
        address spender
    ) external view virtual returns (uint256) {
        return _allowance(owner, spender);
    }
    // end::allowance[]


    // tag::approve[]
    /**
     * @inheritdoc IERC20
     */
    function approve(
        address spender,
        uint256 amount
    ) external virtual returns (bool result) {
        _approve(msg.sender, spender, amount);
        // Emit the required event.
        emit IERC20.Approval(msg.sender, spender, amount);
        return true;
    }
    // end::approve[]

    // tag::transfer[]
    /**
     * @inheritdoc IERC20
     */
    function transfer(
        address recipient,
        uint256 amount
    ) public virtual returns (bool result) {
        _transfer(msg.sender, recipient, amount);
        // Emit the required event.
        emit IERC20.Transfer(msg.sender, recipient, amount);
        return true;
    }
    // end::transfer[]

    // tag::transferFrom[]
    /**
     * @inheritdoc IERC20
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool result) {
        _transferFrom(msg.sender, sender, recipient, amount);
        // Emit the required event.
        emit IERC20.Transfer(sender, recipient, amount);
        result = true;
    }
    // end::transferFrom[]

    /* ---------------------------------------------------------------------- */
    /*                               EXTENSIONS                               */
    /* ---------------------------------------------------------------------- */

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _increaseAllowance(msg.sender, spender, addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _decreaseAllowance(msg.sender, spender, subtractedValue);
        return true;
    }

}