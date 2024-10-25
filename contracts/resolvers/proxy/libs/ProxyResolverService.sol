// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {DCDIAwareService} from "contracts/dcdi/aware/libs/DCDIAwareService.sol";
import {IContext} from "contracts/context/interfaces/IContext.sol";
import {IProxyResolver} from "contracts/resolvers/proxy/interfaces/IProxyResolver.sol";

library ProxyResolverService {

    using DCDIAwareService for address;
    using DCDIAwareService for bytes;

    using ProxyResolverService for IProxyResolver;

    function _genResolverDataKey(
        IProxyResolver resolver,
        address consumer
    ) internal pure returns(bytes32) {
        return keccak256(abi.encode(resolver, consumer));
    }

    function _injectResolverData(
        bytes memory data,
        IProxyResolver resolver,
        address consumer
    ) internal {
        data
            ._injectData(
                consumer,
                resolver._genResolverDataKey(consumer)
            );
    }

    function _loadResolverData(
        IContext context,
        IProxyResolver resolver,
        address consumer
    ) internal view returns(bytes memory) {
        return address(context)
            ._queryInjectedData(
                consumer,
                resolver._genResolverDataKey(consumer)
            );
    }

}