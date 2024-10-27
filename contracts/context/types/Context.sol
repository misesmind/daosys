// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;


import {IContext} from "daosys/context/interfaces/IContext.sol";
import {
    IPackage,
    IContextInitializer
} from "daosys/context/intializers/interfaces/IContextInitializer.sol";
import {ContextInitializerAdaptor} from "daosys/context/intializers/libs/ContextInitializerAdaptor.sol";
import {DCDIFactoryService} from "daosys/dcdi/factory/libs/DCDIFactoryService.sol";

contract Context is IContext {

    using ContextInitializerAdaptor for IContextInitializer;
    using DCDIFactoryService for bytes;

    /**
     * @inheritdoc IContext
     */
    function deployContract(
        bytes memory initCode,
        bytes memory initData
    ) public virtual
    returns(address deployment) {
        deployment = initCode._deploySelfIDInjection(initData);
    }

    /**
     * @inheritdoc IContext
     */
    function deployWithIniter(
        IContextInitializer initer,
        IPackage pkg,
        bytes memory pkgArgs
    ) public virtual
    returns(address deployment) {
        (
            bytes memory initCode,
            bytes32 salt,
            bytes memory initData
        ) = initer._initContext(
            pkg,
            pkgArgs
        );

        deployment = initCode
            ._create2WithInjection(
            // bytes memory initCode,
            // bytes32 salt,
            salt,
            // bytes memory initData
            initData
        );
    }

}