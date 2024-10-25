// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import {DCDIFactoryService} from "contracts/dcdi/factory/libs/DCDIFactoryService.sol";
import {IContext} from "contracts/context/interfaces/IContext.sol";
import {IContextInitializer} from "contracts/context/intializers/interfaces/IContextInitializer.sol";
import {IPackage} from "contracts/context/interfaces/IPackage.sol";
import {OperatableTarget} from "contracts/access/operatable/types/OperatableTarget.sol";
import {ContextInitializerAdaptor} from "contracts/context/intializers/libs/ContextInitializerAdaptor.sol";
import {FactoryService} from "contracts/factory/libs/FactoryService.sol";

contract Context
is
OperatableTarget,
IContext
{

    using ContextInitializerAdaptor for IContextInitializer;
    using DCDIFactoryService for bytes;
    using FactoryService for address;

    constructor() {
        _initOwner(msg.sender);
    }

    // /**
    //  * @inheritdoc IContractContext
    //  */
    function deployContract(
        bytes memory initCode,
        bytes memory initData
    ) public virtual
    // override(IContractContext)
    onlyOwnerOrOperator(msg.sender)
    returns(address deployment) {
        // console.log("entering deployContract");
        // console.log(
        //     "Execution context: %s",
        //     address(this)
        // );
        deployment = initCode._deploySelfIDInjection(initData);
        // console.log(
        //     "Deployed %s",
        //     deployment
        // );
        // console.log("exiting deployContract");
    }

    function deployWithIniter(
        IContextInitializer initer,
        IPackage pkg,
        bytes memory pkgArgs
    ) public virtual
    onlyOwnerOrOperator(msg.sender)
    returns(address deployment) {
        // console.log("entering deployWithIniter");
        // 0x15cF58144EF33af1e14b5208015d11F9143E27b9
        // console.log(
        //     "Execution context: %s",
        //     address(this)
        // );
        // console.log(
        //     "Deploying with initer %s",
        //     address(initer)
        // );
        (
            bytes memory initCode,
            bytes32 salt,
            bytes memory initData
        ) = initer._initContext(
            pkg,
            pkgArgs
        );
        // console.log(
        //     "initCode = "
        // );
        // console.logBytes(initCode);
        // console.log(
        //     "PROXY_INIT_CODE_HASH = "
        // );
        // console.logBytes32(keccak256(initCode));
        // 0x404db9398374873bc26c0d105e2e7e6d5209aa005625ede1907ca590b9dcf37d
        // console.log(
        //     "salt = "
        // );
        // console.logBytes32(salt);
        // console.log(
        //     "initData = "
        // );
        // console.logBytes(initData);
        // console.log(
        //     "Deploying from %s",
        //     address(this)
        // );
        deployment = initCode
            ._create2WithInjection(
            // bytes memory initCode,
            // bytes32 salt,
            salt,
            // bytes memory initData
            initData
        );
        // 0x02de11158f6b81638E4d69bE54B3d50801fa9935
        // 0x79A78b04F7e5e0cCBAe8A0383b67Db05bb42B44b
        // 0xE4D07d4b2Dc4b15c55A28ef592da7868145266b6
        // console.log(
        //     "Deployed %s",
        //     deployment
        // );
        // console.log("exiting deployWithIniter");
    }
    
}