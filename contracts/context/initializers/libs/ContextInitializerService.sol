// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {DCDIAwareService} from "daosys/dcdi/aware/libs/DCDIAwareService.sol";
import {IContext} from "daosys/context/interfaces/IContext.sol";
import {IContextInitializer} from "daosys/context/initializers/interfaces/IContextInitializer.sol";

library ContextInitializerService {

    using DCDIAwareService for address;
    using DCDIAwareService for bytes;

    using ContextInitializerService for IContextInitializer;


    function _genIniterDataKey(
        IContextInitializer initer,
        address consumer
    ) internal pure returns(bytes32) {
        return keccak256(abi.encode(initer, consumer));
    }

    function _injectIniterData(
        bytes memory data,
        IContextInitializer initer,
        address consumer
    ) internal {
        data
            ._injectData(
                consumer,
                initer._genIniterDataKey(consumer)
            );
    }

    function _loadIniterData(
        IContext context,
        IContextInitializer initer,
        address consumer
    ) internal view returns(bytes memory) {
        return address(context)
            ._queryInjectedData(
                consumer,
                initer._genIniterDataKey(consumer)
            );
    }

}