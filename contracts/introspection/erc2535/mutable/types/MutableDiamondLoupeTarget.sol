// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {
    MutableERC2535Service,
    MutableDiamondLoupeStorage,
    IDiamondLoupe
} from "./MutableDiamondLoupeStorage.sol";
import {
    MutableERC165Target
} from "../../../erc165/mutable/types/MutableERC165Target.sol";

contract MutableDiamondLoupeTarget
is IDiamondLoupe, MutableERC165Target, MutableDiamondLoupeStorage {
    
    function _initTarget()
    internal virtual {
        // super._initTarget();
        // _registerInterfaceSupport(type(IDiamondLoupe).interfaceId);
        _initERC165();
    }

  /**
   * @notice Gets all facet addresses and their four byte function selectors.
   * @return facets_ Facet
   */
  function facets()
  external view returns (Facet[] memory facets_) {
    facets_ = _facets();
  }

  /**
   * @notice Gets all the function selectors supported by a specific facet.
   * @param _facet The facet address.
   * @return facetFunctionSelectors_
   */
  function facetFunctionSelectors(address _facet)
  external view returns (bytes4[] memory facetFunctionSelectors_) {
    facetFunctionSelectors_ = _facetFunctionSelectors(_facet);
  }

  /**
   * @notice Get all the facet addresses used by a diamond.
   * @return facetAddresses_
   */
  function facetAddresses()
  external view returns (address[] memory facetAddresses_) {
    facetAddresses_ = _facetAddresses();
  }

  /**
   * @notice Gets the facet that supports the given selector.
   * @dev If facet is not found return address(0).
   * @param _functionSelector The function selector.
   * @return facetAddress_ The facet address.
   */
  function facetAddress(bytes4 _functionSelector)
  external view returns (address facetAddress_) {
    facetAddress_ = _facetAddress(_functionSelector);
  }

    function _supportedInterfaces()
    internal pure virtual override returns(bytes4[] memory supportedInterfaces_)
    {
        supportedInterfaces_ = new bytes4[](1);
        // supportedInterfaces_[0] = type(IERC165).interfaceId;
    }

    function _functionSelectors()
    internal pure virtual override returns(bytes4[] memory funcs_)
    {
        funcs_ = new bytes4[](1);
        // funcs_[0] = IERC165.supportsInterface.selector;
    }

}