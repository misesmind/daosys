// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "daosys/introspection/erc165/interfaces/IERC165.sol";

interface IDCDI {

    error NotFromContext(address challenger);

    /**
     * @dev Contains all components used to calculate a CREATE2 address
     * @param origin The address of the contract that deployed the contract providing this struct.
     * @param initCodeHash The keccak256 hash of the creation code.
     * @param salt The salt used to deploy the contract providing this struct.
     */
    struct Metadata {
        // The address of the contract that deployed the contract providing this struct.
        address origin;
        // The keccak256 hash of the creation code.
        bytes32 initCodeHash;
        // The salt used to deploy the contract providing this struct.
        bytes32 salt;
    }

    /**
     * @return origin_ The address that deployed the contract exposing this interface.
     * @custom:context-exec SAFE IDEMPOTENT
     */
    function origin()
    external view returns(address origin_);

    /**
     * @notice MUST be consistent to execution bytecode regardless of execution context.
     * @return self_ own address.
     * @custom:context-exec SAFE IDEMPOTENT
     */
    function self()
    external view returns(address self_);

    /**
     * @return initCodeHash_ The hash of the creation code used to deploy the exposing contract.
     * @custom:context-exec SAFE IDEMPOTENT
     */
    function initCodeHash()
    external view returns(bytes32 initCodeHash_);

    /**
     * @return salt_ The salt used to deploy the exposing contract with CREATE2.
     */
    function salt()
    external view returns(bytes32 salt_);

    /**
     * @return metadata_ The full Metadata struct containing all CREATE2 variables used to deploy the exposing contract.
     */
    function metadata()
    external view returns(IDCDI.Metadata memory metadata_);

    /**
     * @return initData_ The data injected to initialize the contract exposing this interface.
     */
    function initData()
    external view returns(bytes memory initData_);

    // function supportedInterfaces()
    // external view returns(bytes4[] memory interfaces);

    function postDeploy()
    external returns(bool);

}