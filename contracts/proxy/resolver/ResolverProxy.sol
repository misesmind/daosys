// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import {Proxy} from "daosys/proxy/Proxy.sol";
import {DCDIAware} from "daosys/dcdi/aware/types/DCDIAware.sol";
import {Address} from "daosys/primitives/Address.sol";
import {IProxyResolver} from "daosys/resolvers/proxy/interfaces/IProxyResolver.sol";
import {ProxyResolverAdaptor} from "daosys/resolvers/proxy/libs/ProxyResolverAdaptor.sol";

contract ResolverProxy
is
DCDIAware,
Proxy
{

    using Address for address;
    using ProxyResolverAdaptor for IProxyResolver;

    IProxyResolver private immutable RESOLVER;

    constructor() {
        // console.log("entering constructor");
        // 0xE4D07d4b2Dc4b15c55A28ef592da7868145266b6
        // console.log(
        //     "Execution context: %s",
        //     address(this)
        // );
        RESOLVER = abi.decode(
            _initData(),
            (IProxyResolver)
        );
        RESOLVER._initAccount();
        // console.log("exiting constructor");
    }

    /**
     * @notice get logic implementation address
     * @return target_ DELEGATECALL address target
     */
    function _getTarget()
    internal virtual override returns (address target_) {
        return RESOLVER._getTarget(msg.sig);
    }

}