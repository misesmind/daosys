// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/introspection/erc2535/mutable/types/MutableDiamondCutTarget.sol";
import "daosys/context/erc2535/types/DiamondPackage.sol";
import "daosys/access/ownable/types/OwnableTarget.sol";

contract MutableDiamondCutPackage
is
OwnableTarget,
MutableDiamondCutTarget,
DiamondPackage
{

    function suppoertedInterfaces()
    public view virtual
    override
    returns(bytes4[] memory interfaces) {
        interfaces =  new bytes4[](2);
        interfaces[0] = type(IOwnable).interfaceId;
        interfaces[1] = type(IDiamondCut).interfaceId;
    }

    function facetFuncs()
    public pure returns(bytes4[] memory funcs) {
        funcs = new bytes4[](1);
        funcs[0] = IOwnable.owner.selector;
        funcs[0] = IOwnable.proposedOwner.selector;
        funcs[0] = IOwnable.transferOwnership.selector;
        funcs[0] = IOwnable.acceptOwnership.selector;
        funcs[0] = IOwnable.renounceOwnership.selector;
        funcs[0] = IDiamondCut.diamondCut.selector;
        return funcs;
    }

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

    // function initAccount()
    // public virtual override returns(bytes memory pkgData) {
    //     pkgData = _loadPkgData();
    //     initAccount(pkgData);
    // }

    function initAccount(
        bytes memory initArgs
    ) public virtual override {
        (
            address owner_,
            IDiamond.FacetCut[] memory diamondCut_,
            address initTarget,
            bytes memory initCalldata
        ) = abi.decode(
            initArgs,
            (
                address,
                IDiamond.FacetCut[],
                address,
                bytes
            )
        );
        _initOwner(owner_);
        if(diamondCut_.length > 0) {
            diamondCut(
                diamondCut_,
                initTarget,
                initCalldata
            );
        }
    }

    function diamondCut(
        IDiamond.FacetCut[] memory diamondCut_,
        address initTarget,
        bytes memory initCalldata
    ) public virtual override onlyOwner(msg.sender) {
        super.diamondCut(
            diamondCut_,
            initTarget,
            initCalldata
        );
    }

}