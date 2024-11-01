// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
import "forge-std/console.sol";
// import "forge-std/console2.sol";

import "daosys/introspection/erc2535/mutable/types/MutableDiamondCutTarget.sol";
import "daosys/context/erc2535/types/DiamondPackage.sol";
import "daosys/access/ownable/types/OwnableTarget.sol";
import "daosys/context/erc2535/types/FacetDiamondPackage.sol";

contract MutableDiamondCutPackage
is
OwnableTarget,
MutableDiamondCutTarget,
// DiamondPackage
FacetDiamondPackage
{

    // function supportedInterfaces()
    // public view virtual
    // override
    // returns(bytes4[] memory interfaces) {
    //     interfaces =  new bytes4[](2);
    //     interfaces[0] = type(IOwnable).interfaceId;
    //     interfaces[1] = type(IDiamondCut).interfaceId;
    // }

    function facetInterfaces()
    public view virtual
    override
    returns(bytes4[] memory interfaces) {
        interfaces =  new bytes4[](2);
        interfaces[0] = type(IOwnable).interfaceId;
        interfaces[1] = type(IDiamondCut).interfaceId;
    }

    function facetFuncs()
    public pure virtual override returns(bytes4[] memory funcs) {
        funcs = new bytes4[](6);
        funcs[0] = IOwnable.owner.selector;
        funcs[1] = IOwnable.proposedOwner.selector;
        funcs[2] = IOwnable.transferOwnership.selector;
        funcs[3] = IOwnable.acceptOwnership.selector;
        funcs[4] = IOwnable.renounceOwnership.selector;
        funcs[5] = IDiamondCut.diamondCut.selector;
        // return funcs;
    }

    // function facetCuts()
    // public view virtual override returns(IDiamond.FacetCut[] memory facetCuts_) {
    //     facetCuts_ = new IDiamond.FacetCut[](1);
    //     facetCuts_[0] = IDiamond.FacetCut({
    //         // address facetAddress;
    //         facetAddress: self(),
    //         // FacetCutAction action;
    //         action: IDiamond.FacetCutAction.Add,
    //         // bytes4[] functionSelectors;
    //         functionSelectors: facetFuncs()
    //     });
    // }

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
            bytes memory diamondCutData_
        ) = abi.decode(
            initArgs,
            (
                address,
                bytes
            )
        );
        _initOwner(owner_);
        if(diamondCutData_.length > 0) {
            (
                IDiamond.FacetCut[] memory diamondCut_,
                address initTarget,
                bytes memory initCalldata
            ) = abi.decode(
                diamondCutData_,
                (
                    IDiamond.FacetCut[],
                    address,
                    bytes
                )
            );
            if(diamondCut_.length > 0) {
                _diamondCut(
                    diamondCut_,
                    initTarget,
                    initCalldata
                );
            }
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