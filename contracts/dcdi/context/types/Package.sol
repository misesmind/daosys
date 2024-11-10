// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {DCDIAware} from "daosys/dcdi/aware/types/DCDIAware.sol";
import {IContext} from "daosys/dcdi/context/interfaces/IContext.sol";
import {IPackage} from "daosys/dcdi/context/interfaces/IPackage.sol";
import {PackageService} from "daosys/dcdi/context/libs/PackageService.sol";

/**
 * @title Package - Common operations for ContextInitializer packages.
 * @author cyotee doge <doge.cyotee>
 */
abstract contract Package
is
// Package need to acces ijected data.
DCDIAware,
IPackage
{

    using PackageService for bytes;
    using PackageService for IContext;
    using PackageService for IPackage;

    /**
     * @return ABI encoded injected data fom the Context for the new proxy.
     */
    function _loadPkgData()
    internal view virtual returns(bytes memory) {
        return _loadPkgData(
            IContext(msg.sender),
            address(this)
        );
    }

    /**
     * @return ABI encoded injected data fom the Context for `consumer`.
     */
    function _loadPkgDataFor(address consumer)
    internal view virtual returns(bytes memory) {
        return _loadPkgData(
            IContext(address(this)),
            consumer
        );
    }

    /**
     * @return ABI encoded injected data fom the `context` for `consumer`.
     */
    function _loadPkgData(
        IContext context,
        address consumer
    ) internal view virtual returns(bytes memory) {
        return PackageService
            ._loadPkgData(
                // IContext(origin()),
                context,
                IPackage(self()),
                consumer
            );
    }

    /**
     * @inheritdoc IPackage
     */
    function processArgs(
        bytes memory pkgArgs
    ) public view virtual returns(bytes32 salt) {
        return keccak256(abi.encode(self(), pkgArgs));
    }

    /**
     * @inheritdoc IPackage
     */
    function initContext(
        address consumer,
        bytes memory initArgs
    ) public virtual returns(bool success) {
        PackageService._injectPkgData(
            initArgs,
            IPackage(self()),
            consumer
        );
        return true;
    }

    /**
     * @inheritdoc IPackage
     */
    function initAccount()
    public virtual returns(bytes memory pkgData);

    /**
     * @inheritdoc IPackage
     */
    function postDeploy(
        address consumer
    ) public virtual returns(bool success);

}