// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Address} from "contracts/primitives/Address.sol";
import {IPackage} from "contracts/context/interfaces/IPackage.sol";

library PackageAdaptor {

    using Address for address;

    function _processArgs(
        IPackage pkg,
        bytes memory pkgArgs
    ) internal returns(bytes32 salt) {
        return abi.decode(
            address(pkg)
                ._delegateCall(
                    IPackage.processArgs.selector,
                    abi.encode(pkgArgs)
                ),
            (bytes32)
        );
    }

    function _initContext(
        IPackage pkg,
        address consumer,
        bytes memory initArgs
    ) internal returns(bool) {
        return abi.decode(
            address(pkg)
                ._delegateCall(
                    IPackage.initContext.selector,
                    abi.encode(
                        consumer,
                        initArgs
                    )
                ),
            (bool)
        );
    }

    function _initAccount(
        IPackage pkg
    ) internal returns(bytes memory) {
        return abi.decode(
            address(pkg)
                ._delegateCall(
                    IPackage.initAccount.selector
                ),
            (bytes)
        );
    }

}