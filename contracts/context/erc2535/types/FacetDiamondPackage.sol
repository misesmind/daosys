// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/context/types/Package.sol";
import "daosys/context/erc2535/types/DiamondPackage.sol";

abstract contract FacetDiamondPackage
is 
DiamondPackage
{

    function facetFuncs()
    public view virtual returns(bytes4[] memory funcs);

    function facetCuts()
    public view virtual override returns(IDiamond.FacetCut[] memory facetCuts_) {
        facetCuts_ = new IDiamond.FacetCut[](1);
        facetCuts_[0] = IDiamond.FacetCut({
            // address facetAddress;
            facetAddress: _self(),
            // FacetCutAction action;
            action: IDiamond.FacetCutAction.Add,
            // bytes4[] functionSelectors;
            functionSelectors: facetFuncs()
        });
    }

}