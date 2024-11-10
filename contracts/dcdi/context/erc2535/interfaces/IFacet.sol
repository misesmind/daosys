// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title IFacet - Interface for contracts declaring themselves as viable for use as a Facet of a Diamond proxy.
 * @author cyotee doge <doge.cyotee>
 */
interface IFacet {

    /**
     * @dev ONLY includes interface expected to be called through a proxy.
     * @dev DOES NOT include ANY interface expected to be called directly.
     * @dev Defines the functions in THIS contract mapped into deployed proxies.
     * @return interfaces The ERC165 interface IDs exposed by this Facet.
     */
    function facetInterfaces()
    external view returns(bytes4[] memory interfaces);

    /**
     * @return funcs Function selectors for mapping for usage within a Diamond Proxy.
     */
    function facetFuncs()
    external view returns(bytes4[] memory funcs);

}