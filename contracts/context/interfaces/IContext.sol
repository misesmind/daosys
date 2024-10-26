// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {
    IPackage,
    IContextInitializer
} from "daosys/context/intializers/interfaces/IContextInitializer.sol";
// import "./IPackage.sol";

interface IContext {

    function deployContract(
        bytes memory initCode,
        bytes memory initData
    ) external returns(address deployment);

    function deployWithIniter(
        IContextInitializer initer,
        IPackage pkg,
        bytes memory pkgArgs
    ) external returns(address deployment);

}