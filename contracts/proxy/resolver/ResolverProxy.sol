// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import "daosys/proxy/Proxy.sol";
import "daosys/dcdi/aware/types/DCDIAware.sol";
import "daosys/primitives/Address.sol";
import "daosys/resolvers/proxy/interfaces/IProxyResolver.sol";
import "daosys/resolvers/proxy/libs/ProxyResolverAdaptor.sol";
import "daosys/dcdi/interfaces/IDCDI.sol";

contract ResolverProxy
is
DCDIAware,
Proxy
{

    using Address for address;
    using ProxyResolverAdaptor for IProxyResolver;

    IProxyResolver private immutable RESOLVER;

    constructor() {
        RESOLVER = abi.decode(
            initData(),
            (IProxyResolver)
        );
        RESOLVER._initAccount();
    }

    /**
     * @notice get logic implementation address
     * @return target_ DELEGATECALL address target
     */
    function _getTarget()
    internal virtual override returns (address target_) {
        return RESOLVER._getTarget(msg.sig);
    }

    // function supportedInterfaces()
    // public view virtual override returns(bytes4[] memory interfaces) {
    //     interfaces = new bytes4[](1);
    //     interfaces[0] = type(IDCDI).interfaceId;
    // }

}