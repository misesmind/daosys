// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import {IContextInitializer} from "daosys/context/initializers/interfaces/IContextInitializer.sol";
import {Address} from "daosys/primitives/Address.sol";
import "daosys/dcdi/aware/types/DCDIAware.sol";
import {ProxyResolverService} from "daosys/resolvers/proxy/libs/ProxyResolverService.sol";
import {ProxyResolverAdaptor} from "daosys/resolvers/proxy/libs/ProxyResolverAdaptor.sol";
import {PackageAdaptor} from "daosys/context/libs/PackageAdaptor.sol";
import {
    IDiamondLoupe,
    MutableDiamondLoupeStorage
} from "daosys/introspection/erc2535/mutable/types/MutableDiamondLoupeStorage.sol";
import {ContextInitializerService} from "daosys/context/initializers/libs/ContextInitializerService.sol";
import {FactoryService} from "daosys/factory/libs/FactoryService.sol";
import {IPackage, PackageService} from "daosys/context/libs/PackageService.sol";
import "daosys/proxy/resolver/ResolverProxy.sol";
import "daosys/context/interfaces/IContext.sol";
import "daosys/resolvers/proxy/interfaces/IProxyResolver.sol";
import "daosys/introspection/erc2535/mutable/types/MutableDiamondLoupeTarget.sol";
import "daosys/introspection/erc2535/interfaces/IDiamond.sol";
import "daosys/context/erc2535/interfaces/IDiamondPackage.sol";
import "daosys/context/erc2535/interfaces/IFacet.sol";
import "daosys/context/erc2535/types/FacetDiamondPackage.sol";

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

    address immutable loupeFacet;

    constructor() {
        loupeFacet = abi.decode(initData(), (address));
        _initERC165(supportedInterfaces());
    }

    function initContext(
        IPackage pkg,
        bytes memory pkgArgs
    ) public returns(
        bytes memory initCode,
        bytes32 salt_,
        bytes memory initData_
    ) {
        salt_ = pkg._processArgs(pkgArgs);
        address consumer_ = address(this)
            ._create2AddressFrom(
                PROXY_INIT_CODE_HASH,
                salt_
            );
        bytes memory initerData_ = abi.encode(address(pkg));
        initerData_
            ._injectIniterData(
                IContextInitializer(self()),
                consumer_
            );
        pkg._initContext(consumer_, pkgArgs);
        initData_ = abi.encode(self());
        initCode = PROXY_INIT_CODE;
    }

    function initAccount()
    public override(IContextInitializer, IProxyResolver) returns(bool success) {
        IDiamond.FacetCut[] memory loupeFacetCuts_ = facetCuts();
        _processFacetCuts(
            loupeFacetCuts_
        );
        _initERC165(facetInterfaces());
        bytes memory initerData_ =
        // IContext(origin())
        IContext(msg.sender)
            ._loadIniterData(
                IContextInitializer(self()),
                address(this)
            );
        emit IDiamond.DiamondCut(
            loupeFacetCuts_,
            self(),
            initerData_
        );
        IPackage pkg = IPackage(
            abi.decode(
                initerData_,
                (address)
            )
        );
        IDiamondPackage.DiamondConfig memory config = IDiamondPackage(address(pkg)).diamondConfig();
        _processFacetCuts(
            config.facetCuts_
        );
        _initERC165(config.interfaces);
        bytes memory pkgData_ = pkg._initAccount();
        emit IDiamond.DiamondCut(
            config.facetCuts_,
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

    function supportedInterfaces()
    public view virtual
    // override
    returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](4);
        interfaces[0] = type(IERC165).interfaceId;
        interfaces[1] = type(IDCDI).interfaceId;
        interfaces[2] = type(IContextInitializer).interfaceId;
        interfaces[3] = type(IProxyResolver).interfaceId;
    }

    function facetInterfaces()
    public view virtual
    // override
    returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](3);
        interfaces[0] = type(IERC165).interfaceId;
        interfaces[1] = type(IDCDI).interfaceId;
        interfaces[2] = type(IDiamondLoupe).interfaceId;
    }

    function facetCuts()
    public view returns(IDiamond.FacetCut[] memory facetCuts_) {
        facetCuts_ = new IDiamond.FacetCut[](1);
        facetCuts_[0] = IDiamond.FacetCut({
            // address facetAddress;
            facetAddress: loupeFacet,
            // FacetCutAction action;
            action: IDiamond.FacetCutAction.Add,
            // bytes4[] functionSelectors;
            functionSelectors: IFacet(loupeFacet).facetFuncs()
        });
    }

    function diamondConfig()
    public view returns(IDiamondPackage.DiamondConfig memory config) {
        config = IDiamondPackage.DiamondConfig({
            facetCuts_: facetCuts(),
            interfaces: facetInterfaces()
        });
    }

    // function facetFuncs()
    // public pure returns(bytes4[] memory funcs) {
    //     funcs = new bytes4[](4);
    //     funcs[0] = IDiamondLoupe.facets.selector;
    //     funcs[1] = IDiamondLoupe.facetFunctionSelectors.selector;
    //     funcs[2] = IDiamondLoupe.facetAddresses.selector;
    //     funcs[3] = IDiamondLoupe.facetAddress.selector;
    // }

}