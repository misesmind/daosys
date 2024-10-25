// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IPackage} from "../../interfaces/IPackage.sol";

import {IDiamond} from "../../../introspection/erc2535/interfaces/IDiamond.sol";

interface IDiamondPackage is IPackage {

    // TODO Move to Diamond Package interface.
    function facetCuts()
    external view returns(IDiamond.FacetCut[] memory facetCuts_);

}