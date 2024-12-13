// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import {DCDIFactoryService} from "daosys/dcdi/factory/libs/DCDIFactoryService.sol";
import {IContext} from "daosys/dcdi/context/interfaces/IContext.sol";
import {IContextInitializer} from "daosys/dcdi/context/initializers/interfaces/IContextInitializer.sol";
import {IPackage} from "daosys/dcdi/context/interfaces/IPackage.sol";
import {
    OperatableModifiers
} from "daosys/access/operatable/types/OperatableModifiers.sol";
import {OperatableTarget} from "daosys/access/operatable/types/OperatableTarget.sol";
import {ContextInitializerAdaptor} from "daosys/dcdi/context/initializers/libs/ContextInitializerAdaptor.sol";
import {FactoryService} from "daosys/factory/libs/FactoryService.sol";
import "daosys/dcdi/context/types/Context.sol";
import {
    OwnableTarget
} from "contracts/access/ownable/types/OwnableTarget.sol";

/**
 * @title OperatableContext - Limits deployments ot ONE Owner and MANY Operators.
 * @author cyotee doge <doge.cyotee>
 */
contract OperatableContext
is
Context
,OwnableTarget
,OperatableModifiers
,OperatableTarget
{

    using ContextInitializerAdaptor for IContextInitializer;
    using DCDIFactoryService for bytes;
    using FactoryService for address;

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