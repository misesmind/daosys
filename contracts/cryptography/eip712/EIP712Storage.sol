// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.20;

import {MessageHashUtils} from "daosys/cryptography/MessageHashUtils.sol";
import {ShortStrings, ShortString} from "daosys/storage/ShortStrings.sol";
import {IERC5267} from "daosys/access/erc5267/IERC5267.sol";

struct EIP712Layout {
    bytes32 _cachedDomainSeparator;
    uint256 _cachedChainId;
    address _cachedThis;

    bytes32 _hashedName;
    bytes32 _hashedVersion;

    ShortString _name;
    ShortString _version;
    string _nameFallback;
    string _versionFallback;
}

library EIP712Repo {

    // tag::slot[]
    /**
     * @dev Provides the storage pointer bound to a Struct instance.
     * @param table Implicit "table" of storage slots defined as this Struct.
     * @return slot_ The storage slot bound to the provided Struct.
     */
    function slot(
        EIP712Layout storage table
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
        EIP712Layout storage table
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
    ) external pure returns(EIP712Layout storage layout_) {
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
    ) internal pure returns(EIP712Layout storage layout_) {
        assembly{layout_.slot := slot_}
    }
    // end::_layout[]

}

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable
 */
abstract contract EIP712Storage
// is IERC5267
{


    /* ------------------------------ LIBRARIES ----------------------------- */

    using EIP712Repo for EIP712Layout;
    using ShortStrings for *;

    /* ------------------------- EMBEDDED LIBRARIES ------------------------- */

    // Normally handled by usage for storage slot.
    // Included to facilitate automated audits.
    address constant EIP712Repo_ID
        = address(EIP712Repo);

    /* ---------------------------------------------------------------------- */
    /*                                 STORAGE                                */
    /* ---------------------------------------------------------------------- */

    /* -------------------------- STORAGE CONSTANTS ------------------------- */
  
    // Defines the default offset applied to all provided storage ranges for use when operating on a struct instance.
    // Subtract 1 from hashed value to ensure future usage of relevant library address.
    bytes32 constant internal EIP712Repo_STORAGE_RANGE_OFFSET
        = bytes32(uint256(keccak256(abi.encode(EIP712Repo_ID))) - 1);

    // The default storage range to use with the Repo libraries consumed by this library.
    // Service libraries are expected to coordinate operations in relation to a interface between other Services and Repos.
    bytes32 internal constant EIP712Repo_STORAGE_RANGE
        = type(IERC5267).interfaceId;
    bytes32 internal constant EIP712Repo_STORAGE_SLOT
        = EIP712Repo_STORAGE_RANGE
        ^ EIP712Repo_STORAGE_RANGE_OFFSET;

    // tag::_eip721()[]
    function _eip721()
    internal pure virtual returns(EIP712Layout storage) {
        return EIP712Repo._layout(EIP712Repo_STORAGE_SLOT);
    }
    // end::_eip721()[]

    bytes32 constant TYPE_HASH
        = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    // bytes32 private immutable _cachedDomainSeparator;
    // uint256 private immutable _cachedChainId;
    // address private immutable _cachedThis;

    // bytes32 private immutable _hashedName;
    // bytes32 private immutable _hashedVersion;

    // ShortString private immutable _name;
    // ShortString private immutable _version;
    // string private _nameFallback;
    // string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     */
    function _initEIP721(
        string memory name, string memory version
    ) internal {
        _eip721()._name = name.toShortStringWithFallback(_eip721()._nameFallback);
        _eip721()._version = version.toShortStringWithFallback(_eip721()._versionFallback);
        _eip721()._hashedName = keccak256(bytes(name));
        _eip721()._hashedVersion = keccak256(bytes(version));

        _eip721()._cachedChainId = block.chainid;
        _eip721()._cachedDomainSeparator = _buildDomainSeparator();
        _eip721()._cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _eip721()._cachedThis && block.chainid == _eip721()._cachedChainId) {
            return _eip721()._cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _eip721()._hashedName, _eip721()._hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    // /**
    //  * @dev See {IERC-5267}.
    //  */
    // function eip712Domain()
    //     public
    //     view
    //     virtual
    //     returns (
    //         bytes1 fields,
    //         string memory name,
    //         string memory version,
    //         uint256 chainId,
    //         address verifyingContract,
    //         bytes32 salt,
    //         uint256[] memory extensions
    //     )
    // {
    //     return (
    //         hex"0f", // 01111
    //         _EIP712Name(),
    //         _EIP712Version(),
    //         block.chainid,
    //         address(this),
    //         bytes32(0),
    //         new uint256[](0)
    //     );
    // }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _name which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _eip721()._name.toStringWithFallback(_eip721()._nameFallback);
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _version which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _eip721()._version.toStringWithFallback(_eip721()._versionFallback);
    }
}
