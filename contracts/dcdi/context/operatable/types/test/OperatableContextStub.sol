// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import {DCDIFactoryService} from "daosys/dcdi/factory/libs/DCDIFactoryService.sol";
import {IContext} from "daosys/dcdi/context/interfaces/IContext.sol";
import {IContextInitializer} from "daosys/dcdi/context/initializers/interfaces/IContextInitializer.sol";
import {IPackage} from "daosys/dcdi/context/interfaces/IPackage.sol";
import {OperatableTarget} from "daosys/access/operatable/types/OperatableTarget.sol";
import {ContextInitializerAdaptor} from "daosys/dcdi/context/initializers/libs/ContextInitializerAdaptor.sol";
import {FactoryService} from "daosys/factory/libs/FactoryService.sol";
import "daosys/dcdi/context/operatable/types/OperatableContext.sol";

contract OperatableContextStub
is
OperatableContext
{


    constructor() {
        _initOwner(msg.sender);
    }

    
}