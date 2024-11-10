// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title IPackage = Generalized proxy intialization hooks.
 * @author cyotee doge <doge.cyotee>
 */
interface IPackage {

    /**
     * @dev Provides a preprocessing hook for packages to normalize and/or decorate user provided arguments.
     * @dev User provided arguments may be returned unaltered if no processing is required.
     * @notice The returned initArgs will be used by a DomainController to calculate the CREATE2 salt to be used when instantiating a DomainMemberProxy.
     * @param pkgArgs The ABI encoded arguments the user is providing to the package.
     * return initArgs The arguments to be used to initialize the chain state for a new DomainMemberProxy instance.
     */
    function processArgs(
        bytes memory pkgArgs
    ) external view returns(bytes32 salt);

    /**
     * @dev State changing processing hook for packages to initialize chain state for a new proxy instance.
     * @param consumer The address oof the yet to be instantiated proxy.
     * @param initArgs The processed arguments to be used to initialize chain state for a new proxy instance.
     */
    function initContext(
        address consumer,
        bytes memory initArgs
    ) external returns(bool success);

    /**
     * @dev Proxy intialization hooks.
     * @dev DELEGATECALLed by a ContextInitializer inside the proxy's execution context.
     * @return The ABI encoded data used to initialize the proxy. WILL BE emited in any relevant events.
     */
    function initAccount()
    external returns(bytes memory);

    /**
     * @dev Post deploy hook.
     * @dev Intended for an operations that MUST be taken AFTER deployment AND/OR within the context's execution context.
     * @dev DELEGATECALLed by a ContextInitializer inside the context's execution context.
     * @param consumer_ The address of tthe deployed proxy.
     */
    function postDeploy(
        address consumer_
    ) external returns(bool success);

}