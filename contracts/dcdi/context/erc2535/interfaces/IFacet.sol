// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @title IFacet - Interface for contracts declaring themselves as viable for use as a Facet of a Diamond proxy.
 * @author cyotee doge <doge.cyotee>
 */
interface IFacet {

    /**
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