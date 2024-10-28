// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {DCDIAware} from "daosys/dcdi/aware/types/DCDIAware.sol";
import {IContext} from "daosys/context/interfaces/IContext.sol";
import {IPackage} from "daosys/context/interfaces/IPackage.sol";
import {PackageService} from "daosys/context/libs/PackageService.sol";

abstract contract Package
is
DCDIAware,
IPackage
{

    using PackageService for bytes;
    using PackageService for IContext;
    using PackageService for IPackage;

    function _loadPkgData()
    internal view virtual returns(bytes memory) {
        return PackageService
            ._loadPkgData(
                IContext(_origin()),
                IPackage(_self()),
                address(this)
            );
    }

    function processArgs(
        bytes memory pkgArgs
    ) public view virtual returns(bytes32 salt) {
        // address yieldSource = abi.decode(
        //     pkgArgs,
        //     (address)
        // );
        return keccak256(bytes.concat(abi.encode(_self()), pkgArgs));
    }

    function initContext(
        address consumer,
        bytes memory initArgs
    ) public virtual returns(bool success) {
        PackageService._injectPkgData(
            initArgs,
            IPackage(_self()),
            consumer
        );
        return true;
    }

    function initAccount()
    public virtual returns(bytes memory pkgData);

}