// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import {IDiamond} from "contracts/introspection/erc2535/interfaces/IDiamond.sol";

interface IPackage {

    // TODO Move to Diamond Package interface.
    // function facetCuts()
    // external view returns(IDiamond.FacetCut[] memory facetCuts_);

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
     * @dev State changing processing hook for packages to initialize chain state for a new DomainMemberProxy instance.
     * @param consumer The address oof the yet to be instantiated DomainMemberProxy.
     * @param initArgs The processed arguments to be used to initialize chain state for a new DomainMemberProxy instance.
     */
    function initContext(
        address consumer,
        bytes memory initArgs
    ) external returns(bool success);

    function initAccount(
        // address origin_
    ) external returns(bytes memory);

    function postDeploy(
        address consumer_
    ) external returns(bool success);

}