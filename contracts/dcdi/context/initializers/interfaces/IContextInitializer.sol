// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IPackage} from "daosys/dcdi/context/interfaces/IPackage.sol";

interface IContextInitializer {

    function initContext(
        IPackage pkg,
        bytes memory pkgArgs
    ) external returns(
        bytes memory initCode,
        bytes32 salt,
        bytes memory initData
    );

    function initAccount()
    external returns(bool success);

    function postDeploy()
    external returns(bool success);

}