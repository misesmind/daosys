// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {MutableDiamondLoupeTarget, MutableERC2535Service} from "contracts/introspection/erc2535/mutable/types/MutableDiamondLoupeTarget.sol";
import {Proxy} from "../Proxy.sol";

contract MutableDiamondProxy is Proxy, MutableDiamondLoupeTarget {

    /**
     * @notice get logic implementation address
     * @return target_ DELEGATECALL address target
     */
    function _getTarget()
    internal virtual override returns (address target_) {
        target_ = _facetAddress(msg.sig);
    }

    function _supportedInterfaces()
    internal pure virtual override returns(bytes4[] memory supportedInterfaces_)
    {
        supportedInterfaces_ = new bytes4[](1);
        // supportedInterfaces_[0] = type(IERC165).interfaceId;
    }

    function _functionSelectors()
    internal pure virtual override returns(bytes4[] memory funcs_)
    {
        funcs_ = new bytes4[](1);
        // funcs_[0] = IERC165.supportsInterface.selector;
    }

}