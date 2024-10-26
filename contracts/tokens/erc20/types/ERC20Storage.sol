// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "../../../utils/primitives/Primitives.sol";

/* ---------------------------------- ERC20 --------------------------------- */

import {IERC20Errors, IERC20} from "daosys/tokens/erc20/interfaces/IERC20.sol";
import {ERC20Layout, ERC20Repo} from "daosys/tokens/erc20/libs/ERC20Repo.sol";

/**
 * @title ERC20Storage Diamond Storage ERC20 logic.
 * @author mises mind <misesmind@proton.me>
 * @notice Implements ERC20 compliant logic following Diamond Storage.
 * @notice May be inherited into other contracts to simplify proxy safe implmentations.
 */
abstract contract ERC20Storage is IERC20Errors {

    /* ------------------------------ LIBRARIES ----------------------------- */

    using ERC20Repo for ERC20Layout;

    /* ------------------------- EMBEDDED LIBRARIES ------------------------- */

    // TODO Replace with address of deployed library.
    // Normally handled by usage for storage slot.
    // Included to facilitate automated audits.
    // address constant ERC20LAYOUT_ID = address(ERC20Layout);
    address constant ERC20LAYOUT_ID = address(uint160(uint256(keccak256(type(ERC20Repo).creationCode))));

    /* ---------------------------------------------------------------------- */
    /*                                 STORAGE                                */
    /* ---------------------------------------------------------------------- */

    /* -------------------------- STORAGE CONSTANTS ------------------------- */
  
    // Defines the default offset applied to all provided storage ranges for use when operating on a struct instance.
    // Subtract 1 from hashed value to ensure future usage of relevant library address.
    bytes32 constant internal ERC20_STORAGE_RANGE_OFFSET = bytes32(uint256(keccak256(abi.encode(ERC20LAYOUT_ID))) - 1);

    // The default storage range to use with the Layout libraries consumed by this library.
    // Service libraries are expected to coordinate operations in relation to a interface between other Services and Repos.
    bytes32 internal constant ERC20_STORAGE_RANGE = type(IERC20).interfaceId;
    bytes32 internal constant ERC20_STORAGE_SLOT = ERC20_STORAGE_RANGE ^ ERC20_STORAGE_RANGE_OFFSET;

    // tag::_erc20()[]
    /**
     * @dev internal hook for the default storage range used by this library.
     * @dev Other services will use their default storage range to ensure consistant storage usage.
     * @return The default storage range used with repos.
     */
    function _erc20()
    internal pure virtual returns(ERC20Layout storage) {
        return ERC20Repo._layout(ERC20_STORAGE_SLOT);
    }
    // end::_erc20()[]

    /* ---------------------------------------------------------------------- */
    /*                             INITIALIZATION                             */
    /* ---------------------------------------------------------------------- */

    // tag::_initERC20(string,string,uint8)[]
    /**
     * @dev Set minimal values REQUIRED per ERC20.
     * @dev Allows for 0 supply tokens that expose external supply management.
     * @param name The value to set as the token name.
     * @param symbol The value to set as the token symbol.
     * @param decimals The value to set as the token precision.
     */
    function _initERC20(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal {
        ERC20Storage._setMetadata(
            name,
            symbol,
            decimals
        );
    }
    // end::_initERC20(string,string,uint8)[]

    // tag::_setMetdata(string,string,uint8)[]
    /**
     * @dev Named as Setter as there is no related Metadata member.
     * @param name The value to set as the token name.
     * @param symbol The value to set as the token symbol.
     * @param decimals The value to set as the token precision.
     */
    function _setMetadata(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal {
        _erc20().name = name;
        _erc20().symbol = symbol;
        _erc20().decimals = decimals;
    }
    // end::_setMetdata(string,string,uint8)[]

    function _setMetadata(
        string memory name,
        string memory symbol
    ) internal {
        _erc20().name = name;
        _erc20().symbol = symbol;
    }

    /* ---------------------------------------------------------------------- */
    /*                            UTILITY FUNCTIONS                           */
    /* ---------------------------------------------------------------------- */

    // tag::_mint(uint256,address)
    /**
     * @dev Normalizes argument order to ERC4626.
     * @dev Allows for minting to address(0) to support tokens such as UniswapV2Pair.
     * @param amount Amount by which to increase total supply and credit `account`.
     * @param account The account to be credited with the `amount`.
     */
    function _mint(
        uint256 amount,
        address account
    ) internal virtual returns (uint256 mintedAmount) {
        ERC20Storage._totalSupply(ERC20Storage._totalSupply() + amount);
        ERC20Storage._increaseBalanceOf(account, amount);
        mintedAmount = amount;
    }
    // end::_mint(uint256,address)

    // tag::_burn(uint256,address)
    /**
     * @dev Normalizes argument order to ERC4626.
     * @param amount Amount by which to decrease the total supply and debit `account`.
     * @param account Account to be debited by the `amount`.
     */
    function _burn(
        uint256 amount,
        address account
    ) internal virtual {
        // Decrease the total supply by `amount`.
        // Should naturally revert for underflow.
        ERC20Storage._totalSupply( ERC20Storage._totalSupply() - amount);
        // Decrease the balance of the `acount` by `amouunt`.
        ERC20Storage._decreaseBalanceOf(account, amount);
    }
    // end::_burn(uint256,address)

    // tag::_increaseBalanceOf(address,uint256)[]
    /**
     * @param account The account for which to increase it's balance by `amount`.
     * @param amount The amount by which to increase the balance of `account`.
     */
    function _increaseBalanceOf(
        address account,
        uint256 amount
    ) internal {
        // Increase the balance of `account` by `amount`.
        ERC20Storage._balanceOf(
            account,
            // Load the current balance of `account` and add the `amount`.
            // Should naturally revert for overflow.
            ERC20Storage._balanceOf(account) + amount
        );
    }
    // end::_increaseBalanceOf(address,uint256)[]

    // tag::_decreaseBalanceOf(address,uint256)[]
    /**
     * @param account The account for which to decease it's balance by `amount`.
     * @param amount The amount by which to decrease the balance of `account`.
     */
    function _decreaseBalanceOf(
        address account,
        uint256 amount
    ) internal {
        // Load the current balance of `account`.
        uint256 senderBalance = _balanceOf(account);
        if(senderBalance < amount) {
            // Revert if `account` balance is insufficient.
            revert ERC20InsufficientBalance(account, senderBalance, amount);
        }
        // Decrease the balance of `account` of `amount`.
        ERC20Storage._balanceOf(
            account,
            // Load the current balance of `account` and subtract the `amount`.
            senderBalance - amount
        );
    }
    // end::_decreaseBalanceOf(address,uint256)[]

    // tag::_increaseAllowance(address,address,uint256)[]
    /**
     * @dev DOES NOT emit event as that is for exposing implementation.
     * @param owner Account for which to increase the spending limit for `spender`.
     * @param spender Account for which to increase the spending limit of `owner`.
     * @param amount The amount by which to increase the spending limit of `spender` for `owner`.
     */
    function _increaseAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        // Set the increased spending limit of `spender` for `owner`.
        ERC20Storage._approve(
            owner,
            spender,
            // Load the current spending limit and add the `amount`.
            // Should naturally revert for overflow.
            ERC20Storage._allowance(owner, spender) + amount
        );
    }
    // end::_increaseAllowance(address,address,uint256)[]

    // tag::_decreaseAllowance(address,address,uint256)[]
    /**
     * @dev DOES NOT emit event as that is for exposing implementation.
     * @param owner The account for which to decresae the spending limit for `spender`.
     * @param spender The account for which to decrease the spending limit of `owner`.
     * @param amount The amount by which decrease the spending limit of `spender` for `owner`.
     */
    function _decreaseAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        // Set the increased spending limit of `spender` for `owner`.
        ERC20Storage._approve(
            owner,
            spender,
            // Load the current spending limit and subtract the `amount`.
            ERC20Storage._allowance(owner, spender) - amount
        );
    }
    // end::_decreaseAllowance(address,address,uint256)[]

    /* ---------------------------------------------------------------------- */
    /*                                OVERRIDES                               */
    /* ---------------------------------------------------------------------- */

    /* ---------------------------------------------------------------------- */
    /*                                  LOGIC                                 */
    /* ---------------------------------------------------------------------- */

    // tag::_name()[]
    /**
     * @dev Provides the value of the related Sruct member.
     * @return The token name member value from the related Struct.
     */
    function _name()
    internal view virtual returns (string memory) {
        return _erc20().name;
    }
    // end:_name()[]

    // tag::_symbol()[]
    /**
     * @dev Provides the value of the related Sruct member.
     * @return The token symbol member value from the related Struct.
     */
    function _symbol()
    internal view virtual returns (string memory) {
        return _erc20().symbol;
    }
    // end::_symbol()[]

    // tag::_decimals[]
    /**
     * @return precision Stated precision for determining a single unit of account.
     */
    function _decimals()
    internal view virtual returns (uint8 precision) {
        return _erc20().decimals;
    }
    // end::_decimals[]

    // tag::_totalSupply[]
    /**
     * @notice query the total minted token supply
     * @return supply token supply.
     */
    function _totalSupply()
    internal view virtual returns (uint256 supply) {
        return _erc20().totalSupply;
    }
    // end::_totalSupply[]

    // tag::_totalSupply(uint256)
    /**
     * @dev Sets the totalSupply member of the related Struct.
     * @param newTotalSupply Value to store as the token's totalSupply.
     */
    function _totalSupply(
        uint256 newTotalSupply
    ) internal virtual {
        _erc20().totalSupply = newTotalSupply;
    }
    // end::_totalSupply(uint256)

    // tag::_balanceOf(address)[]
    /**
     * @notice query the token balance of given account
     * @param account address to query for `balance`.
     * @return balance `account` balance.
     */
    function _balanceOf(
        address account
    ) internal view virtual returns (uint256 balance) {
        // Returns the balance of `account`.
        balance = _erc20().balanceOf[account];
    }
    // end::_balanceOf(address)[]

    // tag::_balanceOf(address,uint256[]
    /**
     * @notice Update the balance of `account`.
     * @param account Account to update with `newBalance`.
     * @param newBalance Amount to set as balance for `account`.
     */
    function _balanceOf(
        address account,
        uint256 newBalance
    ) internal virtual {
        _erc20().balanceOf[account] = newBalance;
    }
    // end::_balanceOf(address,uint256[]

    // tag::_approve(address,address,uint256)[]
    /**
     * @dev DOES NOT emit event as that is for exposing implementation.
     * @param owner The account issuing the spending limit approval.
     * @param spender The account being approved with a spending a limit.
     * @param amount The spending limit.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        // address(0) MAY NEVER issue a spending limit approval.
        if(owner == address(0)) {
            // Revert for address(0).
            revert ERC20InvalidReceiver(owner);
        }
        // address(0) MAY NEVER recieve a spending limit approval.
        if(spender == address(0)) {
            // Revert for address(0).
            revert ERC20InvalidReceiver(spender);
        }
        // Set the spending limit of `spender` for `owner`.
        _erc20().allowances[owner][spender] = amount;
    }
    // end::_approve(address,address,uint256)[]

    // tag::_allowance(address,address)[]
    /**
     * @param owner The account of which to query spending limits.
     * @param spender The account of which to query it's spending limit.
     * @return The spending limit of `spender` for `owner`.
     */
    function _allowance(
        address owner,
        address spender
    ) internal view virtual returns (uint256) {
        // Return the spending limit of `spender` for `owner`.
        return _erc20().allowances[owner][spender];
    }
    // end::_allowance(address,address)[]

    // tag::_transfer(address,address,uint256)[]
    /**
     * @dev DOES NOT emit event as that is for exposing implementation.
     * @param sender The account to tansfer `amount` to `recipient`.
     * @param recipient The account to be transfered `amount` from `sender`.
     * @param amount The amount to transfer from `sender` to `recipient`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        // address(0) MAY NEVER spend it's balance.
        if(msg.sender == address(0)) {
            // Revert if address(0).
            revert ERC20InvalidSpender(msg.sender);
        }
        // Decrease the balance of `sender` by `amount`.
        ERC20Storage._decreaseBalanceOf(sender, amount);
        // Increase the balance of `recipient` by `amount`.
        ERC20Storage._increaseBalanceOf(recipient, amount);
    }
    // end::_transfer(address,address,uint256)[]

    // tag::_transferFrom(address,address,uint256)[]
    /**
     * @dev DOES NOT emit event as that is for exposing implementation.
     * @param spender The account transfering `amount` to `recipient` from `sender`.
     * @param sender The account sending `amount` to `recipient`.
     * @param recipient The account receiving `amount` from `sender`.
     * @param amount The amount to transfer from `sender` to `recipient`.
     */
    function _transferFrom(
        address spender,
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        // Load the current spending limit of `spender` for `sender`.
        uint256 currentAllowance = _allowance(sender, spender);
        // Do not allow transfers by `spender` that exceed their spending limit.
        if(currentAllowance < amount) {
            // Revert if `spender` lacks sufficient spending limit.
            revert ERC20InsufficientAllowance(sender, currentAllowance, amount);
        }
        // Decrease the spending limit of `spender` for `sender`.
        ERC20Storage._decreaseAllowance(sender, spender,  amount);
        // Transfer `amount` from `sender` to `recipient`.
        ERC20Storage._transfer(sender, recipient, amount);
    }
    // end::_transferFrom(address,address,uint256)[]

}