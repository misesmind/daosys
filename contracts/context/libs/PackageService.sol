// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {DCDIAwareService} from "contracts/dcdi/aware/libs/DCDIAwareService.sol";
import {IContext} from "contracts/context/interfaces/IContext.sol";
import {IPackage} from "contracts/context/interfaces/IPackage.sol";

library PackageService {

    using DCDIAwareService for address;
    using DCDIAwareService for bytes;

    using PackageService for IPackage;

    function _genPkgDataKey(
        IPackage pkg,
        address consumer
    ) internal pure returns(bytes32) {
        return keccak256(abi.encode(pkg, consumer));
    }

    function _injectPkgData(
        bytes memory data,
        IPackage pkg,
        address consumer
    ) internal {
        data
            ._injectData(
                consumer,
                pkg._genPkgDataKey(consumer)
            );
    }

    function _loadPkgData(
        IContext context,
        IPackage pkg,
        address consumer
    ) internal view returns(bytes memory) {
        return address(context)
            ._queryInjectedData(
                consumer,
                pkg._genPkgDataKey(consumer)
            );
    }

}