// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {Address} from "daosys/primitives/Address.sol";
import {Bytecode} from "daosys/primitives/Bytecode.sol";

/**
 * @title Library to serve as the primary integration point for consumers of immutable blob storage.
 * @author mises mind
 * @dev Implemented as internal functions to simplify development.
 * @dev Will be externalized as part of unit testing.
 */
// TODO Implement SSTORE2 copy operations based on providing pointer
// TODO Implement SSTORE2Map copy operations with pointer and key.
/*
TODO Consider efficient appending functionality to create "journaling" blob storage system of same types.
Will likely require a standard to prepend the SSTORE2 pointer to the begining of the blob to act as the "link" to the "previous" layer.
This would end up being similar to Docker storing layers as "appended" to previous layers.
Read will have to be a reconstruction process allowing for defining how many "layers" to load to handle blobs that exceed maximum available memory.
Would also allow for abi.decode() variable length data that was abi.encodePacked() by storing the variable length data as a discrete layer.
Ideally, this would be able to handle blobs built from abitrary types. With each "layer" being restricted to types that be safely abi.encodePacked().
It should be reasonable to expect reader to know what type they will be retrieving.

Might be possible to do this with current code by prepending an SSTORE2 pointer to data prior to storing.
*/
// TODO Write NatSpec comments.
// TODO Complete unit testinfg for all functions.
// TODO Implement functions for handling primitves as values.
// TODO Consider functions for handling primitves as keys. Unsure if this will be unfeasibely complex.
library ImmutableRepo {

  using Address for address;
  using Address for bytes;
  using Bytecode for address;
  using Bytecode for bytes;
  using Bytecode for bytes32;
  using ImmutableRepo for address;
  using ImmutableRepo for bytes;
  using ImmutableRepo for bytes32;
  using ImmutableRepo for string;

  //                                         keccak256(bytes('@0xSequence.SSTORE2Map.slot'))
  bytes32 internal constant STORAGE_RANGE_OFFSET = 0xd351a9253491dfef66f53115e9e3afda3b5fdef08a1de6937da91188ec553be5;
  // We skip the first byte as it's a STOP opcode to ensure the contract can't be called.
  uint256 internal constant DATA_OFFSET = 1;

  function _salt(
    bytes32 storageRange
  ) internal pure returns (bytes32) {
    // Mutate the key so it doesn't collide
    // if the contract is also using CREATE3 for other things
    return keccak256(abi.encode(STORAGE_RANGE_OFFSET, storageRange));
  }

  function _genKey(
    address key
  ) internal pure returns(bytes32 encodedKey) {
    encodedKey = key._toBytes32();
  }

  function _pointerFromOf(
    address writer,
    bytes32 key
  ) internal pure returns (address) {
    return writer._create3AddressFromOf(key._salt());
  }

  /**
   * @notice Calcuates the address at which a blob "mapped" under the provided key would be stored.
   * @param key The CREATE2 salt used with the CREATE3 and SSTORE2 design patterns.
   */
  function _pointerOf(
    bytes32 key
  ) internal view returns (address) {
    return key._salt()._create3AddressOf();
  }

//   function _pointerFromOf(
//     address writer,
//     address key
//   ) internal pure returns (address) {
//     return writer._pointerFromOf(key._genKey());
//   }

//   function _pointerFromOf(
//     address writer,
//     string calldata key
//   ) internal pure returns (address) {
//     return writer._pointerFromOf(keccak256(bytes(key)));
//   }

  function _pointerOf(
    string calldata key
  ) internal view returns (address) {
    return keccak256(bytes(key))._pointerOf();
  }

  function _recordSizeFromOf(
    address writer,
    bytes32 key
  ) internal view returns(uint256 size) {
    size = writer._pointerFromOf(key)._codeSizeOf();
  }

  function _recordSizeOf(
    bytes32 key
  ) internal view returns(uint256 size) {
    size = key._pointerOf()._codeSizeOf();
  }

  function _recordSizeOf(
    string calldata key
  ) internal view returns(uint256 size) {
    size = key._pointerOf()._codeSizeOf();
  }

  function _isPresentFrom(
    address writer,
    bytes32 key
  ) internal view returns(bool isPresent) {
    isPresent = (writer._recordSizeFromOf(key) > 0);
  }

  function _isPresent(
    bytes32 key
  ) internal view returns(bool isPresent) {
    isPresent = (key._recordSizeOf() > 0);
  }

  function _writeBlob(
    bytes memory blob
  ) internal returns(address pointer) {
    // Prefix the bytecode with a STOP opcode to ensure it cannot be called.
    bytes memory runtimeCode = abi.encodePacked(hex"00", blob);

    bytes memory creationCode = abi.encodePacked(
      //---------------------------------------------------------------------------------------------------------------//
      // Opcode  | Opcode + Arguments  | Description  | Stack View                                                     //
      //---------------------------------------------------------------------------------------------------------------//
      // 0x60    |  0x600B             | PUSH1 11     | codeOffset                                                     //
      // 0x59    |  0x59               | MSIZE        | 0 codeOffset                                                   //
      // 0x81    |  0x81               | DUP2         | codeOffset 0 codeOffset                                        //
      // 0x38    |  0x38               | CODESIZE     | codeSize codeOffset 0 codeOffset                               //
      // 0x03    |  0x03               | SUB          | (codeSize - codeOffset) 0 codeOffset                           //
      // 0x80    |  0x80               | DUP          | (codeSize - codeOffset) (codeSize - codeOffset) 0 codeOffset   //
      // 0x92    |  0x92               | SWAP3        | codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset)   //
      // 0x59    |  0x59               | MSIZE        | 0 codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset) //
      // 0x39    |  0x39               | CODECOPY     | 0 (codeSize - codeOffset)                                      //
      // 0xf3    |  0xf3               | RETURN       |                                                                //
      //---------------------------------------------------------------------------------------------------------------//
      hex"60_0B_59_81_38_03_80_92_59_39_F3", // Returns all code in the contract except for the first 11 (0B in hex) bytes.
      runtimeCode // The bytecode we want the contract to have after deployment. Capped at 1 byte less than the code size limit.
    );

    /// @solidity memory-safe-assembly
    assembly {
      // Deploy a new contract with the generated creation code.
      // We start 32 bytes into the code to avoid copying the byte length.
      pointer := create(0, add(creationCode, 32), mload(creationCode))
    }

    require(pointer != address(0), "DEPLOYMENT_FAILED");
  }

  function writeBlob(
    bytes memory blob
  ) external returns(address pointer) {
    pointer = blob._writeBlob();
  }

  function _readBlob(
    address pointer
  ) internal view returns(bytes memory blob) {
    blob = pointer._codeAt(DATA_OFFSET, pointer.code.length - DATA_OFFSET);
  }

  function readBlob(
    address pointer
  ) external view returns(bytes memory blob) {
    blob = pointer._readBlob();
  }

  function _readBlobStart(
    address pointer,
    uint256 start
  ) internal view returns (bytes memory) {
    start += DATA_OFFSET;

    return pointer._codeAt(start, pointer.code.length - start);
  }

  function _readBlobRange(
    address pointer,
    uint256 start,
    uint256 end
  ) internal view returns (bytes memory) {
    start += DATA_OFFSET;
    end += DATA_OFFSET;

    require(pointer.code.length >= end, "OUT_OF_BOUNDS");
    return pointer._codeAt(start, end - start);
  }

  /**
   * @param key The key to be used to salt the deployment of blobs. Allows for "finding" blobs through CREAT2 address recalculation.
   * @param blob The data in raw bytes to be stored through SSTORE2Map using Create3.
   * @return pointer The address of the deployed blob.
   */
  // TODO Swithc argument order.
  function _mapBlob(
    bytes memory blob,
    bytes32 key
  ) internal returns(address pointer) {
    // Append 00 to _data so contract can't be called
    // Build init code
    bytes memory code = abi.encodePacked(hex'00', blob)._initCodeFor();

    // Deploy contract using create3
    pointer = code._create3(key._salt());
  }

  /**
   * @param key The key to be used to salt the deployment of blobs. Allows for "finding" blobs through CREAT2 address recalculation.
   * @param blob The data in raw bytes to be stored through SSTORE2Map using Create3.
   * @return pointer The address of the deployed blob.
   */
  function mapBlob(
    bytes memory blob,
    bytes32 key
  ) external returns(address pointer) {
    pointer = blob._mapBlob(key);
  }

//   function _mapBlob(
//     bytes memory blob,
//     address key
//   ) internal returns(address pointer) {
//     pointer = blob._mapBlob(key._genKey());
//   }
  
//   /**
//     @notice Stores `_data` and returns `pointer` as key for later retrieval
//     @dev The pointer is a contract address with `_data` as code
//     @param blob To be written
//     @param key unique string key for accessing the written data (can only be used once)
//     @return pointer Pointer to the written `_data`
//   */
//   function _mapBlob(
//     bytes memory blob,
//     string memory key
//   ) internal returns (address pointer) {
//     pointer = blob._mapBlob(keccak256(bytes(key)));
//   }
  
//   /**
//     @notice Stores `_data` and returns `pointer` as key for later retrieval
//     @dev The pointer is a contract address with `_data` as code
//     @param blob To be written
//     @param key unique string key for accessing the written data (can only be used once)
//     @return pointer Pointer to the written `_data`
//   */
//   function mapBlob(
//     bytes memory blob,
//     string memory key
//   ) external returns (address pointer) {
//     pointer =  blob._mapBlob(key);
//   }

  /**
   * @notice Reads the contents for a given `key`, it maps to a contract code as data, skips the first byte
   * @dev The function is intended for reading pointers first written by `write`
   * @dev Allows for reading SSTORE2 records written from a provided writer address.
   * @param key bytes32 key that constains the data
   * @param writer The address of the writer to read the value found under the provided key.
   * @return data The data read from contract associated with `key`
   */
  function _queryBlobFromOf(
    address writer,
    bytes32 key
  ) internal view returns (bytes memory data) {
    return writer._create3AddressFromOf(key._salt())._codeAt(1, type(uint256).max);
  }

  function queryBlobFromOf(
    address writer,
    bytes32 key
  ) external view returns(bytes memory blob) {
    blob = writer._queryBlobFromOf(key);
  }

  /**
   * @param key The salt used to write the desired blob the same execution context.
   * @return blob The blob to be loaded from the address pointer calculated from the provided key and the address of the execution context.
   */
  function _queryBlobOf(
    bytes32 key
  ) internal view returns(bytes memory blob) {
    blob = key._salt()._create3AddressOf()._codeAt(1, type(uint256).max);
  }

  function queryBlobOf(
    bytes32 key
  ) external view returns(bytes memory blob) {
    blob = key._queryBlobOf();
  }

  /**
    @notice Reads the contents for a given `key`, it maps to a contract code as data, skips the first byte
    @dev The function is intended for reading pointers first written by `write`
    @param key bytes32 key that constains the data
    @param start number of bytes to skip
    @return data read from contract associated with `key`
  */
  function _queryBlobOfStart(
    bytes32 key,
    uint256 start
  ) internal view returns (bytes memory) {
    return key._salt()._create3AddressOf()._codeAt(start + 1, type(uint256).max);
  }

  /**
    @notice Reads the contents for a given `key`, it maps to a contract code as data, skips the first byte
    @dev The function is intended for reading pointers first written by `write`
    @param key bytes32 key that constains the data
    @param start number of bytes to skip
    @return data read from contract associated with `key`
  */
  function queryBlobOfStart(
    bytes32 key,
    uint256 start
  ) external view returns (bytes memory) {
    return key._queryBlobOfStart(start);
  }

  /**
   * @notice Reads the contents for a given `key`, it maps to a contract code as data, skips the first byte
   * @dev The function is intended for reading pointers first written by `write`
   * @param key bytes32 key that constains the data
   * @param start number of bytes to skip
   * @param end index before which to end extraction
   * @return data read from contract associated with `key`
   */
  function _queryBlobOfRange(
    bytes32 key,
    uint256 start,
    uint256 end
  ) internal view returns (bytes memory) {
    return key._salt()._create3AddressOf()._codeAt(start + 1, end + 1);
  }

  /**
   * @notice Reads the contents for a given `key`, it maps to a contract code as data, skips the first byte
   * @dev The function is intended for reading pointers first written by `write`
   * @param key bytes32 key that constains the data
   * @param start number of bytes to skip
   * @param start index before which to end extraction
   * @return data read from contract associated with `key`
   */
  function queryBlobOfRange(
    bytes32 key,
    uint256 start,
    uint256 end
  ) external view returns (bytes memory) {
    return key._queryBlobOfRange(start, end);
  }

//   /**
//     @notice Reads the contents for a given `key`, it maps to a contract code as data, skips the first byte
//     @dev The function is intended for reading pointers first written by `write`
//     @param key string key that constains the data
//     @return data read from contract associated with `key`
//   */
//   function _queryBlobOf(
//     string memory key
//   ) internal view returns (bytes memory) {
//     return keccak256(bytes(key))._queryBlobOf();
//   }

//   /**
//     @notice Reads the contents for a given `key`, it maps to a contract code as data, skips the first byte
//     @dev The function is intended for reading pointers first written by `write`
//     @param key string key that constains the data
//     @return data read from contract associated with `key`
//   */
//   function queryBlobOf(
//     string memory key
//   ) external view returns (bytes memory) {
//     return key._queryBlobOf();
//   }

//   /**
//     @notice Reads the contents for a given `key`, it maps to a contract code as data, skips the first byte
//     @dev The function is intended for reading pointers first written by `write`
//     @param key string key that constains the data
//     @param start number of bytes to skip
//     @return data read from contract associated with `key`
//   */
//   function _queryBlobOfStart(
//     string memory key,
//     uint256 start
//   ) internal view returns (bytes memory) {
//     return keccak256(bytes(key))._queryBlobOfStart(start);
//   }

//   /**
//    * @notice Reads the contents for a given `key`, it maps to a contract code as data, skips the first byte
//    * @dev The function is intended for reading pointers first written by `write`
//    * @param key string key that constains the data
//    * @param start number of bytes to skip
//    * @param end index before which to end extraction
//    * @return data read from contract associated with `key`
//    */
//   function _queryBlobOfRange(
//     string memory key,
//     uint256 start,
//     uint256 end
//   ) internal view returns (bytes memory) {
//     return keccak256(bytes(key))._queryBlobOfRange(start, end);
//   }

//   /**
//    * @notice Reads the contents for a given `key`, it maps to a contract code as data, skips the first byte
//    * @dev The function is intended for reading pointers first written by `write`
//    * @param key string key that constains the data
//    * @param start number of bytes to skip
//    * @param end index before which to end extraction
//    * @return data read from contract associated with `key`
//    */
//   function queryBlobOfRange(
//     string memory key,
//     uint256 start,
//     uint256 end
//   ) external view returns (bytes memory) {
//     return key._queryBlobOfRange(start, end);
//   }

//   function _mapAddress(
//     address value,
//     bytes32 key
//   ) internal returns(address pointer) {
//     pointer = value._marshall()._mapBlob(key);
//   }

//   function mapAddress(
//     address value,
//     bytes32 key
//   ) external returns(address pointer) {
//     pointer = value._mapAddress(key);
//   }

//   function _mapAddress(
//     address value,
//     address key
//   ) internal returns(address pointer) {
//     pointer = value._mapAddress(key._genKey());
//   }

//   function mapAddress(
//     address value,
//     address key
//   ) external returns(address pointer) {
//     pointer = value._mapAddress(key);
//   }

//   function _queryAddressOf(
//     bytes32 key
//   ) internal view returns(address value) {
//     value = key._queryBlobOf()._asAddress();
//   }

//   function queryAddressOf(
//     bytes32 key
//   ) external view returns(address value) {
//     value = key._queryAddressOf();
//   }

//   function _queryAddressFromOf(
//     address writer,
//     bytes32 key
//   ) internal view returns(address value) {
//     value = writer._queryBlobFromOf(key)._asAddress();
//   }

//   function queryAddressFromOf(
//     address writer,
//     bytes32 key
//   ) external view returns(address value) {
//     value = writer._queryAddressFromOf(key);
//   }

//   function _queryAddressFromOf(
//     address writer,
//     address key
//   ) internal view returns(address value) {
//     value = writer._queryAddressFromOf(key._genKey());
//   }

//   function queryAddressFromOf(
//     address writer,
//     address key
//   ) external view returns(address value) {
//     value = writer._queryAddressFromOf(key);
//   }

//   function _queryBlobFromOf(
//     address writer,
//     address key
//   ) internal view returns(bytes memory value) {
//     value = writer._queryBlobFromOf(key._genKey());
//   }

//   function queryBlobFromOf(
//     address writer,
//     address key
//   ) external view returns(bytes memory value) {
//     value = writer._queryBlobFromOf(key);
//   }

//   function _mapBytes4Array(
//     bytes4[] memory value,
//     bytes32 key
//   ) internal returns(address pointer) {
//     pointer = abi.encode(value)._mapBlob(key);
//   }

//   function _queryBytes4ArrayOf(
//     bytes32 key
//   ) internal view returns(bytes4[] memory value) {
//     value = abi.decode(
//       key._queryBlobOf(),
//       (bytes4[])
//     );
//   }

  // /* -------------------------------------------------------------------------- */
  // /*                                  ILibrary                                  */
  // /* -------------------------------------------------------------------------- */

  // /* ----------------------- Internal Type Declarations ----------------------- */

  // function _libName()
  // internal pure returns(string memory libName_) {
  //   libName_ = type(ImmutableRepo).name;
  // }

  // /* ----------------------- External Type Declarations ----------------------- */

  // function libTypeId()
  // external pure returns(bytes4 libTypeId_) {
  //   libTypeId_ = _libTypeId();
  // }

  // function libName()
  // external pure returns(string memory libName_) {
  //   libName_ = _libName();
  // }

  // /* -------------------------------------------------------------------------- */
  // /*                                    IRepo                                   */
  // /* -------------------------------------------------------------------------- */

  // /* ----------------------- Internal Type Declarations ----------------------- */

  // /**
  //  * @dev bytes(0) indicates immutable storage.
  //  */
  // function _storageOffset()
  // internal pure returns(bytes32 storageOffset_) {
  //   storageOffset_ = bytes32(0);
  // }

  // /* ----------------------- External Type Declarations ----------------------- */

  // function storageOffset()
  // external pure returns(bytes32 storageSlotOffset) {
  //   storageSlotOffset = _storageOffset();
  // }

}