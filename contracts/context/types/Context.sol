// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;


import {IContext} from "daosys/context/interfaces/IContext.sol";
import {
    IPackage,
    IContextInitializer
} from "daosys/context/initializers/interfaces/IContextInitializer.sol";
import {ContextInitializerAdaptor} from "daosys/context/initializers/libs/ContextInitializerAdaptor.sol";
import {DCDIFactoryService} from "daosys/dcdi/factory/libs/DCDIFactoryService.sol";
import "daosys/introspection/erc165/mutable/types/MutableERC165Target.sol";
/**
 * @title Context - Extendable arbitrary deployment factory.
 * @author cyotee doge <doge.cyotee>
 * @notice Allows anyone to deploy bytecode to a deterministic address.
 * @notice Provides a hookable deployment process to extend functionality.
 */
contract Context is MutableERC165Target, IContext {

    using ContextInitializerAdaptor for IContextInitializer;
    using DCDIFactoryService for bytes;

    constructor() {
        _initERC165(suppoertedInterfaces());
    }

    function suppoertedInterfaces()
    public view virtual returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](2);
        interfaces[0] = type(IERC165).interfaceId;
        interfaces[0] = type(IContext).interfaceId;
    }

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