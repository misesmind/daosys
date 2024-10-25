// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import "contracts/context/intializers/interfaces/IContextInitializer.sol";
import "contracts/utils/Address.sol";
import "contracts/resolvers/proxy/erc2535/types/MutableERC2535ProxyResolver.sol";
import "contracts/dcdi/aware/types/DCDIAware.sol";
import "contracts/resolvers/proxy/libs/ProxyResolverService.sol";
import "contracts/resolvers/proxy/libs/ProxyResolverAdaptor.sol";
import "contracts/dcdi/aware/libs/PackageAdaptor.sol";
import {
    MutableDiamondLoupeStorage
} from "contracts/ercs/introspection/erc2535/types/MutableDiamondLoupeStorage.sol";
import "contracts/context/libs/ContextInitializerService.sol";
import "contracts/factory/libs/FactoryService.sol";
import "contracts/dcdi/aware/libs/PackageService.sol";
import "contracts/proxy/resolver/ResolverProxy.sol";
import "contracts/context/libs/ContextInitializerService.sol";
import "contracts/context/interfaces/IContext.sol";
// import "contracts/ercs/introspection/erc2535/interfaces/IDiamondLoupe.sol";
import "contracts/resolvers/proxy/interfaces/IProxyResolver.sol";
import "contracts/ercs/introspection/erc2535/types/MutableDiamondLoupeTarget.sol";

contract MutableERC2535ContextInitializer
is
DCDIAware,
MutableDiamondLoupeTarget,
IDiamond,
IProxyResolver,
IContextInitializer
{

    using ContextInitializerService for IContext;
    using ContextInitializerService for bytes;
    using FactoryService for address;
    using PackageAdaptor for IPackage;
    // using PackageService for address;
    using PackageService for IContext;
    using ProxyResolverService for address;
    using ProxyResolverService for bytes;

    bytes constant PROXY_INIT_CODE = type(ResolverProxy).creationCode;
    bytes32 constant PROXY_INIT_CODE_HASH = keccak256(PROXY_INIT_CODE);

    // IProxyResolver immutable resolver_;

    constructor() {
        // resolver_ = abi.decode(_initData(), (IProxyResolver));
    }

    function initContext(
        IPackage pkg,
        bytes memory pkgArgs
    ) public returns(
        bytes memory initCode,
        bytes32 salt,
        bytes memory initData_
    ) {
        console.log("entering initContext");
        // 0x15cF58144EF33af1e14b5208015d11F9143E27b9
        console.log(
            "Execution context: %s",
            address(this)
        );
        salt = pkg._processArgs(pkgArgs);
        // 0x404db9398374873bc26c0d105e2e7e6d5209aa005625ede1907ca590b9dcf37d
        console.log(
            "salt = "
        );
        console.logBytes32(salt);
        // 0x0d8fd63e6426e1660f7f5ace07d76ef320121a115835e17a28386486012b469d
        console.log(
            "PROXY_INIT_CODE_HASH = "
        );
        console.logBytes32(PROXY_INIT_CODE_HASH);
        console.log(
            "Deploying from %s",
            address(this)
        );
        address consumer_ = address(this)
            ._create2AddressFrom(
                PROXY_INIT_CODE_HASH,
                salt
            );
        console.log(
            "Deploying to %s",
            consumer_
        );
        // 0xD0f6eDEdB507aF1665b9eEf0E6578DE3EEdb869c.
        // 0xD0f6eDEdB507aF1665b9eEf0E6578DE3EEdb869c.
        console.log(
            "Injecting context initer data for consumer %s.",
            consumer_
        );
        bytes memory initerData_ = abi.encode(address(pkg));
        console.logBytes(initerData_);
        initerData_
            ._injectIniterData(
                IContextInitializer(_self()),
                consumer_
            );
        pkg._initContext(consumer_, pkgArgs);
        initData_ = abi.encode(_self());
        initCode = PROXY_INIT_CODE;
        console.log("exiting initContext");
    }

    function initAccount()
    public override(IContextInitializer, IProxyResolver) returns(bool success) {
        IDiamond.FacetCut[] memory loupeFacetCuts_ = facetCuts();
        _processFacetCuts(
            loupeFacetCuts_
        );
        bytes memory initerData_ = IContext(_origin())
            ._loadIniterData(
                IContextInitializer(_self()),
                address(this)
            );
        console.log("Loaded context initer data.");
        console.logBytes(initerData_);
        emit IDiamond.DiamondCut(
            loupeFacetCuts_,
            _self(),
            initerData_
        );
        IPackage pkg = IPackage(
            abi.decode(
                initerData_,
                (address)
            )
        );
        // TODO add ERC165 support.
        IDiamond.FacetCut[] memory pkgFacetCuts_ = pkg.facetCuts();
        _processFacetCuts(
            pkgFacetCuts_
        );
        bytes memory pkgData_ = pkg._initAccount();
        emit IDiamond.DiamondCut(
            pkgFacetCuts_,
            address(pkg),
            pkgData_
        );
        return true;
    }

    function getTarget(
        bytes4 functionSelector
    ) external view returns(address target_) {
        return _facetAddress(functionSelector);
    }

    function facetCuts()
    public view returns(IDiamond.FacetCut[] memory facetCuts_) {
        facetCuts_ = new IDiamond.FacetCut[](4);
        facetCuts_[0] = IDiamond.FacetCut({
            // address facetAddress;
            facetAddress: _self(),
            // FacetCutAction action;
            action: IDiamond.FacetCutAction.Add,
            // bytes4[] functionSelectors;
            functionSelectors: loupeFuncs()
        });
    }

    function loupeFuncs()
    public pure returns(bytes4[] memory funcs) {
        funcs = new bytes4[](4);
        funcs[0] = IDiamondLoupe.facets.selector;
        funcs[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        funcs[2] = IDiamondLoupe.facetAddresses.selector;
        funcs[3] = IDiamondLoupe.facetAddress.selector;
        return funcs;
    }

}