// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {MutableERC165Storage, IERC165} from "daosys/introspection/erc165/mutable/types/MutableERC165Storage.sol";

abstract contract MutableERC165Target is IERC165, MutableERC165Storage {

    // function _initTarget()
    // internal virtual {
    //     _registerInterfaceSupport(type(IERC165).interfaceId);
    // }

    /**
     * @notice query whether contract has registered support for given interface
     * @param interfaceId interface id
     * @return isSupported whether interface is supported
     * @custom:sighash 0x01ffc9a7
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool isSupported) {
        isSupported = _erc165().isSupportedInterface[interfaceId];
    }

}