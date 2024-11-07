// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/dcdi/context/types/Package.sol";
import "daosys/dcdi/context/erc2535/types/DiamondPackage.sol";
import "daosys/dcdi/context/erc2535/types/Facet.sol";

abstract contract FacetDiamondPackage
is
Facet,
DiamondPackage
{

    // function supportedInterfaces()
    // public view virtual override(Facet, DiamondPackage) returns(bytes4[] memory interfaces);

    function facetInterfaces()
    public view virtual override(Facet, DiamondPackage) returns(bytes4[] memory interfaces);

    function facetCuts()
    public view virtual override returns(IDiamond.FacetCut[] memory facetCuts_) {
        facetCuts_ = new IDiamond.FacetCut[](1);
        facetCuts_[0] = IDiamond.FacetCut({
            // address facetAddress;
            facetAddress: self(),
            // FacetCutAction action;
            action: IDiamond.FacetCutAction.Add,
            // bytes4[] functionSelectors;
            functionSelectors: facetFuncs()
        });
    }

}