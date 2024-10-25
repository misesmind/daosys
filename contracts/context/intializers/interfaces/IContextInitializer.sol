// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../../interfaces/IPackage.sol";

interface IContextInitializer {

    function initAccount()
    external returns(bool success);

    function initContext(
        IPackage pkg,
        bytes memory pkgArgs
    ) external returns(
        bytes memory initCode,
        bytes32 salt,
        bytes memory initData
    );

}