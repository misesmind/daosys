// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Permit.sol)

pragma solidity ^0.8.20;

import {IERC2612} from "daosys/access/erc2612/interfaces/IERC2612.sol";
import {ECDSA} from "daosys/cryptography/ECDSA.sol";
import "daosys/access/erc5267/ERC5267Target.sol";
import "daosys/tokens/erc20/types/ERC20Target.sol";

struct ERC2612Layout {
    mapping(address account => uint256) nonces;
}

library ERC2612Repo {

    // /**
    //  * @dev The nonce used for an `account` is not the expected current nonce.
    //  */
    // error CountUsed(address account, uint256 currentNonce);

    // tag::slot[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     */
    function slot(
        ERC2612Layout storage table
    ) external pure returns(bytes32 slot_) {
        return _slot(table);
    }
    // end::slot[]

    // tag::_slot[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     */
    function _slot(
        ERC2612Layout storage table
    ) internal pure returns(bytes32 slot_) {
        assembly{slot_ := table.slot}
    }
    // end::_slot[]

    // tag::layout[]
    /**
     * @dev "Binds" this struct to a storage slot.
     * @param slot_ The first slot to use in the range of slots used by the struct.
     * @return layout_ A struct from a Layout library bound to the provided slot.
     * @custom:sig layout(bytes32)
     * @custom:selector 0x81366cef
     */
    function layout(
        bytes32 slot_
    ) external pure returns(ERC2612Layout storage layout_) {
        return _layout(slot_);
    }
    // end::layout[]

    // tag::_layout[]
    /**
     * @dev "Binds" this struct to a storage slot.
     * @param slot_ The first slot to use in the range of slots used by the struct.
     * @return layout_ A struct from a Layout library bound to the provided slot.
     */
    function _layout(
        bytes32 slot_
    ) internal pure returns(ERC2612Layout storage layout_) {
        assembly{layout_.slot := slot_}
    }
    // end::_layout[]

}


/**
 * @dev Provides tracking nonces for addresses. Nonces will only increment.
 */
abstract contract ERC2612Storage {

    using ERC2612Repo for ERC2612Layout;

    address constant ERC2612Repo_ID = address(ERC2612Repo);
    bytes32 constant internal ERC2612Repo_STORAGE_RANGE_OFFSET
        = bytes32(uint256(keccak256(abi.encode(ERC2612Repo_ID))) - 1);
    bytes32 internal constant ERC2612Repo_STORAGE_RANGE
        = type(IERC2612).interfaceId;
    bytes32 internal constant ERC2612Repo_STORAGE_SLOT
        = ERC2612Repo_STORAGE_RANGE ^ ERC2612Repo_STORAGE_RANGE_OFFSET;
    
    function _permit()
    internal pure virtual returns(ERC2612Layout storage) {
        return ERC2612Repo._layout(ERC2612Repo_STORAGE_SLOT);
    }

    /**
     * @dev The nonce used for an `account` is not the expected current nonce.
     */
    error InvalidAccountNonce(address account, uint256 currentNonce);

    // mapping(address account => uint256) private _nonces;

    // /**
    //  * @dev Returns the next unused nonce for an address.
    //  */
    // function nonces(
    //     address owner
    // ) internal view virtual returns (uint256) {
    //     return _permit().nonces[owner];
    // }

    /**
     * @dev Consumes a nonce.
     *
     * Returns the current value and increments nonce.
     */
    function _useNonce(
        address owner
    ) internal virtual returns (uint256) {
        // For each account, the nonce has an initial value of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here.
            return _permit().nonces[owner]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address owner, uint256 nonce) internal virtual {
        uint256 current = _useNonce(owner);
        if (nonce != current) {
            revert InvalidAccountNonce(owner, current);
        }
    }
}

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
contract ERC2612Target
is
ERC20Target
, ERC5267Target
, ERC2612Storage
, IERC2612
{
    bytes32 private constant PERMIT_TYPEHASH
        = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Permit deadline has expired.
     */
    error ERC2612ExpiredSignature(uint256 deadline);

    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    // constructor(string memory name_) EIP712(name_, "1") {}

    /**
     * @inheritdoc IERC2612
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert ERC2612ExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, value);
    }

    /**
     * @inheritdoc IERC2612
     */
    function nonces(address owner) public view virtual override(IERC2612) returns (uint256) {
        return _permit().nonces[owner];
    }

    /**
     * @inheritdoc IERC2612
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}
