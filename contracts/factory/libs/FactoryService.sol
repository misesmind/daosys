// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {Bytecode} from "../../primitives/Bytecode.sol";

// TODO Write NatSpec comments.
// TODO Complete unit testinfg for all functions.
// TODO Implement and test external versions of all functions.
library FactoryService {

  using Bytecode for address;
  using Bytecode for bytes;

  function _calcInitCodeHash(
    bytes memory initCode
  ) internal pure returns(bytes32 initCodeHash) {
    initCodeHash = initCode._calcInitCodeHash();
  }

  function _create(
    bytes memory initCode
  ) internal returns(address deployment) {
    deployment = initCode._create();
  }

  function create(
    bytes memory initCode
  ) external returns(address deployment) {
    deployment = _create(initCode);
  }

  function _create2(
    bytes memory initCode,
    bytes32 salt
  ) internal returns(address deployment) {
    deployment = initCode._create2(salt);
  }

  function create2(
    bytes memory initCode,
    bytes32 salt
  ) external returns(address deployment) {
    deployment = _create2(initCode, salt);
  }

  function _create2WithArgs(
    bytes memory initCode,
    bytes32 salt,
    bytes memory initArgs
  ) internal returns(address deployment) {
    deployment = initCode._create2WithArgs(
      salt,
      initArgs
    );
  }

  function create2WithArgs(
    bytes memory initCode,
    bytes32 salt,
    bytes memory initArgs
  ) external returns(address deployment) {
    deployment = _create2WithArgs(
      initCode,
      salt,
      initArgs
    );
  }

//   function _create2Clone(
//     address original,
//     bytes32 salt
//   ) internal returns(address clone) {
//     bytes memory code = original._codeAt(0, original.code.length);
//     bytes memory initCode = code._initCodeFor();
//     clone = _create2(initCode, salt);
//   }

//   function create2Clone(
//     address original,
//     bytes32 salt
//   ) external returns(address clone) {
//     clone = _create2Clone(original, salt);
//   }

  /**
   * @notice calculate the _deployMetamorphicContract deployment address for a given salt
   * @param initCodeHash hash of contract initialization code
   * @param salt input for deterministic address calculation
   * @return deployment address
   */
  function _create2AddressFrom(
    address deployer,
    bytes32 initCodeHash,
    bytes32 salt
  ) internal pure returns (address payable) {
    return
      payable(
        address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            deployer,
                            salt,
                            initCodeHash
                        )
                    )
                )
            )
        )
    );
  }

  function create2AddressFrom(
    address deployer,
    bytes32 initCodeHash,
    bytes32 salt
  ) external pure returns (address) {
    return _create2AddressFrom(
      deployer,
      initCodeHash,
      salt
    );
  }

//   /**
//    * @notice calculate the _deployMetamorphicContract deployment address for a given salt
//    * @param initCodeHash hash of contract initialization code
//    * @param salt input for deterministic address calculation
//    * @return deployment address
//    */
//   function _create2AddressFromSelf(
//     bytes32 initCodeHash,
//     bytes32 salt
//   ) internal view returns (address) {
//     return _create2AddressFrom(
//       address(this),
//       initCodeHash,
//       salt
//     );
//   }

//   function create2AddressFromSelf(
//     bytes32 initCodeHash,
//     bytes32 salt
//   ) external view returns (address) {
//     return _create2AddressFromSelf(
//       initCodeHash,
//       salt
//     );
//   }

}