// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

// import {IDCDI} from "../../interfaces/IDCDI.sol";
import {IDCDI, DCDIAwareService} from "contracts/dcdi/aware/libs/DCDIAwareService.sol";
import {FactoryService} from "contracts/factory/libs/FactoryService.sol";

library DCDIFactoryService {

    // using DCDIContractService for bytes;
    using DCDIAwareService for IDCDI.Metadata;
    using FactoryService for bytes;

    using DCDIFactoryService for bytes;
    using DCDIFactoryService for bytes32;

    function _calcSalt(
        bytes32 initCodeHash,
        bytes32 initDataHash
    ) internal pure returns(bytes32) {
        return keccak256(abi.encode(initCodeHash, initDataHash));
    }

    function _calcSalt(
        bytes memory initCode,
        bytes memory initData
    ) internal pure returns(bytes32) {
        return keccak256(initCode)._calcSalt(keccak256(initData));
    }

    /**
     * @dev Will use hash of initCode as CREATE2 salt.
     * @param initCode The creation byteccode to be deployed.
     * @param initData Blob to store using SSTORE2 as initiialization data for initCode.
     */
    function _deploySelfIDInjection(
        bytes memory initCode,
        bytes memory initData
    ) internal returns(address deployment) {
        // console.log("entering _deploySelfIDInjection");
        deployment = initCode._create2WithInjection(
            // We replicate the constructor argument process to simulate the EVM normal behavior.
            // This also allows for duplicate bytecode deployments with differing initialization data.
            initCode._calcSalt(initData),
            initData
        );
        // console.log("exiting _deploySelfIDInjection");
    }

    /**
     * @param initCode The creation byteccode to be deployed.
     * @param salt The CREATE2 salt to use for deployment of initCode.
     * @param initData Blob to store using SSTORE2 as initiialization data for initCode.
     */
    function _create2WithInjection(
        bytes memory initCode,
        bytes32 salt,
        bytes memory initData
    ) internal returns(address deployment) {
        // console.log("entering _create2WithInjection");
        // Calc the init code hash.
        bytes32 initCodeHash = keccak256(initCode);
        // Declare new deployment metadata.
        IDCDI.Metadata memory metadata = IDCDI.Metadata({
            origin: address(this),
            initCodeHash: initCodeHash,
            salt: salt
        });
        // Inject the metadata.
        // TODO Optimize by consolidating the two underlying CREATE2 address calculation.
        metadata._injectMetadata();
        // Check if init data was provided.
        if(initData.length > 0) {
            // Inject init data if present.
            metadata._injectInitData(initData);
        }
        // Deploy bytecode and return deployed address.
        deployment = initCode._create2(salt);
        // console.log("exiting _create2WithInjection");
    }

}