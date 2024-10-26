// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {MutableDiamondProxy, MutableERC2535Service} from "daosys/proxy/diamond/MutableDiamondProxy.sol";
import {IDiamond} from "daosys/introspection/erc2535/interfaces/IDiamond.sol";
import {Address} from "daosys/primitives/Address.sol";

contract MutableDiamondProxyStub is MutableDiamondProxy {

    using Address for address;
    using MutableERC2535Service for IDiamond.FacetCut[];

    constructor(
        IDiamond.FacetCut[] memory facetCuts,
        address initTarget,
        bytes memory initCalldata
    ) {
        _initTarget();
        facetCuts._processFacetCuts();
        if(initTarget != address(0)) {
            initTarget._delegateCall(initCalldata);
        }
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