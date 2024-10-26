// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IDCDI} from "daosys/dcdi/interfaces/IDCDI.sol";
import {FactoryService} from "daosys/factory/libs/FactoryService.sol";
import {ImmutableRepo} from "daosys/storage/ImmutableRepo.sol";
import {Address} from "daosys/primitives/Address.sol";

library DCDIAwareService {

    using Address for address;
    using FactoryService for address;
    using ImmutableRepo for address;
    using ImmutableRepo for bytes;

    using DCDIAwareService for address;
    using DCDIAwareService for bytes;
    using DCDIAwareService for bytes32;
    using DCDIAwareService for IDCDI.Metadata;

    /* -------------------------------------------------------------------------- */
    /*                          Arbitrary DCDI Injection                          */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Checks for the presence of bytecode that may store data.
     * @param writer The address that wrote the injected data.
     * @param consumer The address of the intended consumer of the injected data.
     * @param key The value used as the CREATE2 salt for storing the injected data.
     * @return isInjected Boolean indicating if bytecode is present.
     */
    function _isInjected(
        address writer,
        address consumer,
        bytes32 key
    ) internal view returns(bool isInjected) {
        isInjected = writer._isPresentFrom(keccak256(abi.encode(consumer, key)));
    }

    /**
     * @param data The encoded data to be injected for any domain specific process.
     * @param consumer The address of the intended consumer of the injected data.
     * @param key The value used as the CREATE2 salt for storing the injected data.
     * @return pointer The address under which the the injected data has been stored.
     */
    function _injectData(
        bytes memory data,
        address consumer,
        bytes32 key
    ) internal returns(address pointer) {
        pointer = data._mapBlob(keccak256(abi.encode(consumer, key)));
    }

    /**
     * @param writer The address that wrote the injected data.
     * @param consumer The address of the intended consumer of the injected data.
     * @param key The value used as the CREATE2 salt for storing the injected data.
     */
    function _queryInjectedData(
        address writer,
        address consumer,
        bytes32 key
    ) internal view returns(bytes memory initData) {
        // Double check that data was injected to prevent potential reversion if not present or contains no data.
        initData = _isInjected(writer, consumer, key)
            // If present, load and returns injected datas.
            ? writer._queryBlobFromOf(keccak256(abi.encode(consumer, key)))
            //If NOT present, returns empty bytes.
            : new bytes(0);
        
    }

    /* ---------------------------------------------------------------------- */
    /*                           METADATA Operations                          */
    /* ---------------------------------------------------------------------- */

    /**
     * @dev Recalculates the address from the provided IDCDI.metadata.
     * @param metadata_ The ICreate2Aware.Metadata from which to to recalculate the address.
     * @return target The address from the provided metadata_.
     */
    function _calcAddress(
        IDCDI.Metadata memory metadata_
    ) internal pure returns(address target) {
        // Use the Metadata members to calculate the CREATE2 address.
        target = metadata_.origin._create2AddressFrom(
            metadata_.initCodeHash,
            metadata_.salt
        );
    }

    /**
     * @dev Stores the provided IDCDI.metadata using DCDI using the address as the key.
     * @param metadata The IDCDI.metadata to be stored.
     * @return pointer The address under which the the injected data has been stored.
     */
    function _injectMetadata(
        IDCDI.Metadata memory metadata
    ) internal returns(address pointer) {
        // Calc the adress from the provided IDCDI.metadata.
        address consumer = address(this)._create2AddressFrom(
            metadata.initCodeHash,
            metadata.salt
        );
        // Pass calculated address and metadata for injection.
        pointer = consumer._injectMetadata(metadata);
    }

    /**
     * @dev Stores the provided IDCDI.metadata using DCDI using the address as the key.
     * @param metadata The IDCDI.metadata to be stored.
     * @return pointer The address under which the the injected data has been stored.
     */
    function _injectMetadata(
        address consumer,
        IDCDI.Metadata memory metadata
    ) internal returns(address pointer) {
        // Confirm the IDCDI.metadata matches the provided consumer.
        // If this is wrong, the universe is broken.
        require(consumer == metadata._calcAddress());
        // Inject the metadata.
        // Uses the related address as the "key".
        pointer = abi.encode(metadata)._injectData(
            consumer,
            consumer._toBytes32()
        );
    }

    /**
     * @dev Stores the provided IDCDI.metadata using DCDI using the address as the key.
     * @param consumer The address of the yet to be instantiated ResolverProxy.
     * @param salt The salt to use when deploying the proxy.
     * @return pointer The address under which the the injected data has been stored.
     */
    function _injectMetadata(
        address consumer,
        bytes32 initCodeHash,
        bytes32 salt
    ) internal returns(address pointer) {
        // Construct the IDCDI.metadata for the new Contract.
        IDCDI.Metadata memory metadata = IDCDI.Metadata({
            origin: address(this),
            initCodeHash: initCodeHash,
            salt: salt
        });
        pointer = consumer._injectMetadata(metadata);
    }

    /**
     * @dev Loads the ICreate2Aware.Metadata of the target_.
     * @param origin_ The address that deployed the target_.
     * @param target_ The address of the IDCDI.metadata.
     * @return metadata_ The IDCDI.metadata of the target_.
     */
    function _queryMetadata(
        address origin_,
        address target_
    ) internal view returns(IDCDI.Metadata memory metadata_) {
        metadata_ = abi.decode(
            origin_._queryInjectedData(
                target_,
                target_._toBytes32()
            ),
            (IDCDI.Metadata)
        );
    }

    /**
     * @dev Calculates the default key used to inject contract init data via DCDI.
     * @param initCodeHash The hash of the init code of the contract to consume the injected data.
     * @param salt The CREATE2 salt used to deploy the consuming contract.
     */
    function _calcInitDataKey(
        bytes32 initCodeHash,
        bytes32 salt
    ) internal pure returns(bytes32 initDataKey) {
        initDataKey = initCodeHash ^ salt;
        // TODO Figure out why this breaks.
        // initDataKey = keccak256(abi.encode(initCodeHash, salt));
    }

    /**
     * @param metadata_ The IDCDI.metadata of the contract that will consume the initData.
     * @param initData The data to injected so that it may be consumed by the subject of the metadata_.
     */
    function _injectInitData(
        IDCDI.Metadata memory metadata_,
        bytes memory initData
    ) internal returns(address pointer) {
        pointer = metadata_._calcAddress()._injectInitData(
            initData,
            metadata_.initCodeHash,
            metadata_.salt
        );
    }

    /**
     * @dev Inject data to be consumed by a contract during initialization.
     * @param consumer The address of the contract expected to consume the initData.
     * @param initData The data to be injected for consumption by the consumer.
     * @param initCodeHash The hash of the init code of the contract to consume injected data.
     * @param salt The CREATE2 salt that will be used to deploy the consumer.
     * @return pointer The address under which the the injected data has been stored.
     */
    function _injectInitData(
        address consumer,
        bytes memory initData,
        bytes32 initCodeHash,
        bytes32 salt
    ) internal returns(address pointer) {
        pointer = initData._injectData(
                consumer,
                initCodeHash._calcInitDataKey(salt)
            );
    }

    /**
     * @param consumer The address of the contract expected to consume the initData.
     * @param origin The address that wrote the injected data.
     * @param initCodeHash The hash of the init code of the contract to consume injected data.
     * @param salt The CREATE2 salt that will be used to deploy the consumer.
     * @return initData The data that was injected for consumption by the consumer.
     */
    function _queryInitData(
        address consumer,
        address origin,
        bytes32 initCodeHash,
        bytes32 salt
    ) internal view returns(bytes memory initData) {
        initData = origin._queryInjectedData(
                consumer,
                initCodeHash._calcInitDataKey(salt)
            );
    }

    /**
     * @param metadata_ The IDCDI.metadata of the contract for the initData to load.
     * @return initData_ The data that was injected for consumption by the consumer.
     */
    function _queryInitData(
        IDCDI.Metadata memory metadata_
    ) internal view returns(bytes memory initData_) {
        initData_ = metadata_._calcAddress()._queryInitData(
            metadata_.origin,
            metadata_.initCodeHash,
            metadata_.salt
        );
    }

}