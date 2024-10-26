// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IERC165} from "daosys/introspection/erc165/interfaces/IERC165.sol";
import {ERC165Utils} from "daosys/introspection/erc165/libs/ERC165Utils.sol";

// TODO switch to enumerated version
contract MutableERC165Stub is IERC165 {

    using ERC165Utils for bytes4[];

    /* ---------------------------------------------------------------------- */
    /*                                  STATE                                 */
    /* ---------------------------------------------------------------------- */

    /* ------------------------------- IERC165 ------------------------------ */

    mapping(bytes4 interfaceId => bool isSupported) isSupportedInterface;

    /* ---------------------------------------------------------------------- */
    /*                             INITIALIZATION                             */
    /* ---------------------------------------------------------------------- */

    constructor() {
        _initERC165(_supportedInterfaces());
    }

    /* ------------------------------- IERC165 ------------------------------ */

    function _initERC165(
        bytes4[] memory supportedInterfaces_
    ) internal {
        for(uint256 cursor = 0; cursor < supportedInterfaces_.length; cursor ++) {
            isSupportedInterface[supportedInterfaces_[cursor]] = true;
        }
        isSupportedInterface[_functionSelectors()._calcInterfaceId()] = true;
    }

    /* ---------------------------------------------------------------------- */
    /*                              Declarations                              */
    /* ---------------------------------------------------------------------- */

    /* ------------------------------- IERC165 ------------------------------ */

    function _supportedInterfaces()
    internal pure virtual returns(bytes4[] memory supportedInterfaces_) {
        supportedInterfaces_ = new bytes4[](1);
        supportedInterfaces_[0] = type(IERC165).interfaceId;
    }

    function _functionSelectors()
    internal pure virtual returns(bytes4[] memory funcs_) {
        funcs_ = new bytes4[](1);
        funcs_[0] = IERC165.supportsInterface.selector;
    }

    /* ---------------------------------------------------------------------- */
    /*                                  Logic                                 */
    /* ---------------------------------------------------------------------- */

    /* ------------------------------- IERC165 ------------------------------ */

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(
        bytes4 interfaceId
    ) external view returns (bool isSupported) {
        return isSupportedInterface[interfaceId];
    }

}