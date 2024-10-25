// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Address} from "contracts/primitives/Address.sol";
import {IProxyResolver} from "contracts/resolvers/proxy/interfaces/IProxyResolver.sol";

library ProxyResolverAdaptor {

    using Address for address;

    function _initAccount(
        IProxyResolver resolver
    ) internal {
        address(resolver)
            ._delegateCall(
                IProxyResolver.initAccount.selector
            );
    }

    function _getTarget(
        IProxyResolver resolver,
        bytes4 funcSel
    ) internal returns(address) {
        // address(resolver)
        //     ._delegateCall(
        //         IProxyResolver.initAccount.selector
        //     );
        return abi.decode(
            address(resolver)._delegateCall(
                IProxyResolver.getTarget.selector,
                abi.encode(funcSel)
            ),
            (address)
        );
    }

}