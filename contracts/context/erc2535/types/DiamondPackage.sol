// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/context/types/Package.sol";
import {IDiamond} from "daosys/introspection/erc2535/interfaces/IDiamond.sol";

abstract contract DiamondPackage is Package {

    function initAccount()
    public virtual override returns(bytes memory pkgData) {
        pkgData = _loadPkgData();
        initAccount(pkgData);
    }

    function facetCuts()
    public view virtual returns(IDiamond.FacetCut[] memory facetCuts_);

    function initAccount(
        bytes memory initArgs
    ) public virtual;

}