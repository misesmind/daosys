// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import {DCDIFactoryService} from "daosys/dcdi/factory/libs/DCDIFactoryService.sol";
import {IContext} from "daosys/context/interfaces/IContext.sol";
import {IContextInitializer} from "daosys/context/intializers/interfaces/IContextInitializer.sol";
import {IPackage} from "daosys/context/interfaces/IPackage.sol";
import {OperatableTarget} from "daosys/access/operatable/types/OperatableTarget.sol";
import {ContextInitializerAdaptor} from "daosys/context/intializers/libs/ContextInitializerAdaptor.sol";
import {FactoryService} from "daosys/factory/libs/FactoryService.sol";
import "daosys/context/types/Context.sol";

contract OperatableContext
is
Context,
OperatableTarget
{

    using ContextInitializerAdaptor for IContextInitializer;
    using DCDIFactoryService for bytes;
    using FactoryService for address;

    constructor() {
        _initOwner(msg.sender);
    }

    /**
     * @inheritdoc IContext
     */
    function deployContract(
        bytes memory initCode,
        bytes memory initData
    ) public virtual
    override(Context)
    onlyOwnerOrOperator(msg.sender)
    returns(address deployment) {
        return super.deployContract(initCode, initData);
    }

    /**
     * @inheritdoc IContext
     */
    function deployWithIniter(
        IContextInitializer initer,
        IPackage pkg,
        bytes memory pkgArgs
    ) public virtual
    override(Context)
    onlyOwnerOrOperator(msg.sender)
    returns(address deployment) {
        return super.deployWithIniter(initer, pkg, pkgArgs);
    }
    
}