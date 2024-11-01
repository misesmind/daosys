// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/context/types/Package.sol";
import "daosys/introspection/erc2535/interfaces/IDiamond.sol";
import "daosys/context/erc2535/interfaces/IDiamondPackage.sol";

abstract contract DiamondPackage is Package, IDiamondPackage {

    function initAccount()
    public virtual override(IPackage, Package) returns(bytes memory pkgData) {
        pkgData = _loadPkgData();
        initAccount(pkgData);
    }

    function facetInterfaces()
    public view virtual returns(bytes4[] memory interfaces);

    function facetCuts()
    public view virtual returns(IDiamond.FacetCut[] memory facetCuts_);

    function diamondConfig()
    external view returns(DiamondConfig memory config) {
        config = DiamondConfig({
            facetCuts_: facetCuts(),
            interfaces: facetInterfaces()
        });
    }

    function initAccount(
        bytes memory initArgs
    ) public virtual;

}