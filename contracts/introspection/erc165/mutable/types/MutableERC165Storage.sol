// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MutableERC165Struct, MutableERC165Layout} from "daosys/introspection/erc165/mutable/libs/MutableERC165Layout.sol";
import {IERC165} from "daosys/introspection/erc165/interfaces/IERC165.sol";
import {ERC165Utils} from "daosys/introspection/erc165/libs/ERC165Utils.sol";

abstract contract MutableERC165Storage {

    using ERC165Utils for bytes4[];
    using MutableERC165Layout for MutableERC165Struct;

    address constant MutableERC165Layout_ID =
        address(uint160(uint256(keccak256(type(MutableERC165Layout).creationCode))));
    bytes32 constant internal MutableERC165Layout_STORAGE_RANGE_OFFSET =
        bytes32(uint256(keccak256(abi.encode(MutableERC165Layout_ID))) - 1);
    bytes32 internal constant MutableERC165Layout_STORAGE_RANGE =
        type(IERC165).interfaceId;
    bytes32 internal constant MutableERC165Layout_STORAGE_SLOT =
        MutableERC165Layout_STORAGE_RANGE ^ MutableERC165Layout_STORAGE_RANGE_OFFSET;
    
    function _erc165()
    internal pure virtual returns(MutableERC165Struct storage) {
        return MutableERC165Layout._layout(MutableERC165Layout_STORAGE_SLOT);
    }

    function _initERC165(
        // bytes4[] memory supportedInterfaces_
    ) internal {
        bytes4[] memory supportedInterfaces_ = _supportedInterfaces();
        for(uint256 cursor = 0; cursor < supportedInterfaces_.length; cursor ++) {
            _erc165().isSupportedInterface[supportedInterfaces_[cursor]] = true;
        }
        _erc165().isSupportedInterface[_functionSelectors()._calcInterfaceId()] = true;
    }

    function _supportedInterfaces()
    internal pure virtual returns(bytes4[] memory supportedInterfaces_)
    {
        supportedInterfaces_ = new bytes4[](1);
        supportedInterfaces_[0] = type(IERC165).interfaceId;
    }

    function _functionSelectors()
    internal pure virtual returns(bytes4[] memory funcs_)
    {
        funcs_ = new bytes4[](1);
        funcs_[0] = IERC165.supportsInterface.selector;
    }

}