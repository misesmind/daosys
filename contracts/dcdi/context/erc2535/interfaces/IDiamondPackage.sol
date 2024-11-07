// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IPackage} from "daosys/dcdi/context/interfaces/IPackage.sol";

import {IDiamond} from "daosys/introspection/erc2535/interfaces/IDiamond.sol";

interface IDiamondPackage is IPackage {

    struct DiamondConfig {
        IDiamond.FacetCut[] facetCuts_;
        bytes4[] interfaces;
    }

    /**
     * @return interfaces The ERC165 interface IDs exposed by this Facet.
     */
    function facetInterfaces()
    external view returns(bytes4[] memory interfaces);

    // TODO Move to Diamond Package interface.
    function facetCuts()
    external view returns(IDiamond.FacetCut[] memory facetCuts_);

    function diamondConfig()
    external view returns(DiamondConfig memory config);

    function initAccount(
        bytes memory initArgs
    ) external;

}