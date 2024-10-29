// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Address} from "daosys/primitives/Address.sol";
import {IPackage, IContextInitializer} from "daosys/context/initializers/interfaces/IContextInitializer.sol";

library ContextInitializerAdaptor {

    using Address for address;

    function _initAccount(
        IContextInitializer initer
    ) internal {
        address(initer)
            ._delegateCall(
                IContextInitializer.initAccount.selector
            );
    }

    function _initContext(
        IContextInitializer initer,
        IPackage pkg,
        bytes memory pkgArgs
    ) internal returns(
        bytes memory initCode,
        bytes32 salt,
        bytes memory initData
    ) {
        bytes memory returnData = address(initer)._delegateCall(
            IContextInitializer.initContext.selector,
            abi.encode(pkg, pkgArgs)
        );
        (
            initCode,
            salt,
            initData
        ) = abi.decode(
            returnData,
            (
                bytes,
                bytes32,
                bytes
            )
        );
    }

}