// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
import "forge-std/console.sol";
// import "forge-std/console2.sol";

import "daosys/introspection/erc2535/mutable/types/MutableDiamondCutTarget.sol";
import "daosys/context/erc2535/types/DiamondPackage.sol";
import "daosys/access/ownable/types/OwnableTarget.sol";
import "daosys/context/erc2535/types/FacetDiamondPackage.sol";
import "daosys/access/ownable/types/OwnableModifiers.sol";
import "daosys/dcdi/interfaces/IDCDI.sol";
import "daosys/context/erc2535/interfaces/IDiamondPackage.sol";
import "daosys/introspection/erc165/mutable/types/MutableERC165Target.sol";

contract MutableDiamondCutPackage
is
OwnableModifiers,
MutableERC165Target,
MutableDiamondCutTarget,
// DiamondPackage
FacetDiamondPackage
{
    address immutable ownableFacet;

    constructor() {
        ownableFacet = abi.decode(initData(), (address));
        _initERC165(supportedInterfaces());
    }

    function supportedInterfaces()
    public view virtual
    // override
    returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](4);
        interfaces[0] = type(IERC165).interfaceId;
        interfaces[1] = type(IDCDI).interfaceId;
        interfaces[2] = type(IFacet).interfaceId;
        interfaces[3] = type(IDiamondPackage).interfaceId;
    }

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
        funcs = new bytes4[](1);
        funcs[0] = IDiamondCut.diamondCut.selector;
    }

    function facetCuts()
    public view virtual override returns(IDiamond.FacetCut[] memory facetCuts_) {
        facetCuts_ = new IDiamond.FacetCut[](2);
        facetCuts_[0] = IDiamond.FacetCut({
            // address facetAddress;
            facetAddress: ownableFacet,
            // FacetCutAction action;
            action: IDiamond.FacetCutAction.Add,
            // bytes4[] functionSelectors;
            functionSelectors: IFacet(ownableFacet).facetFuncs()
        });
        facetCuts_[1] = IDiamond.FacetCut({
            // address facetAddress;
            facetAddress: self(),
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

    function postDeploy(
        address consumer
    ) public virtual override(IPackage, Package) returns(bool success) {}

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