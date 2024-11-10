// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/dcdi/context/interfaces/IPackage.sol";
import "daosys/introspection/erc2535/interfaces/IDiamond.sol";

/**
 * @title IDiamondPackage - Interface of declarations and deployment hooks for a ERC2535 based package.
 * @author cyotee doge <doge.cyotee>
 */
interface IDiamondPackage is IPackage {

    /**
     * @dev Structs are better than tuples.
     */
    struct DiamondConfig {
        IDiamond.FacetCut[] facetCuts_;
        bytes4[] interfaces;
    }

    /**
     * @dev ONLY includes interface expected to be called through a proxy.
     * @dev DOES NOT include ANY interface expected to be calledd directly.
     * @dev Defines the functions in THIS contract mapped into deployed proxies.
     * @return interfaces The ERC165 interface IDs exposed by this Facet.
     */
    function facetInterfaces()
    external view returns(bytes4[] memory interfaces);

    /**
     * @return facetCuts_ The IDiamond.FacetCut array to configuring a proxy with this package.
     */
    function facetCuts()
    external view returns(IDiamond.FacetCut[] memory facetCuts_);

    /**
     * @return config Unified function to retrieved `facetInterfaces()` AND `facetCuts()` in one call.
     */
    function diamondConfig()
    external view returns(DiamondConfig memory config);

    /**
     * @dev A standardized proxy initialization function.
     * @dev Included so the init logic used with `diamondCut()` AND a ContextIntializer.
     */
    function initAccount(
        bytes memory initArgs
    ) external;

}