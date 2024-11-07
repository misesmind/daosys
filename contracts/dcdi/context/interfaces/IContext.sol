// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {
    IPackage,
    IContextInitializer
} from "daosys/dcdi/context/initializers/interfaces/IContextInitializer.sol";
import "daosys/dcdi/interfaces/IDCDI.sol";

/**
 * @title IContext - Arbitrary deployment factory interface.
 * @author cyotee doge <doge.cyotee>
 * @notice Allows anyone to deploy byte code to a deterministic address.
 * @notice Provides an optional hookable deployment process to extend functionality.
 */
interface IContext is IDCDI {

    /**
     * @notice Deploys provided bytecode using Create2.
     * @notice Uses DCDI to inject provided initData.
     * @notice Deployment simulates the Create deployment process.
     * @notice salt = keccak256(abi.encode(initCodeHash, initDataHash))
     * @notice Crunstructor arguments MUST be attached BEFORE call.
     * @dev IS DELEGATECALL SAFE.
     * @param initCode_ Creation Code for deployment.
     * @param initData_ Initialization data for DCDI injection for comsumption by new deployment.
     * @return deployment The adress of newly deployed bytecode.
     */
    function deployContract(
        bytes memory initCode_,
        bytes memory initData_
    ) external returns(address deployment);

    /**
     * @notice Hookable deployment process.
     * @dev Package MUST be compatible with ContextInitializer.
     * @param initer Contextinitializer to use as deployment hook.
     * @param pkg DCDI Package to provided to the initer.
     * @return deployment The adress of newly deployed bytecode.
     */
    function deployWithIniter(
        IContextInitializer initer,
        IPackage pkg,
        bytes memory pkgArgs
    ) external returns(address deployment);

    function postDeploy()
    external returns(bool);

}