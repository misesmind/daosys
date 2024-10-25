// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {MutableERC2535Repo, IDiamondLoupe} from "./MutableERC2535Repo.sol";
import {IDiamond} from "contracts/introspection/erc2535/interfaces/IDiamond.sol";
import "../../../erc165/libs/ERC165Utils.sol";

// TODO Write NatSpec comments.
// TODO Complete unit testinfg for all functions.
// TODO Implement and test external versions of all functions.
library MutableERC2535Service {

  using ERC165Utils for bytes4[];
//   using MutableERC165Service for bytes4;
  using MutableERC2535Repo for bytes32;
  using MutableERC2535Service for IDiamond.FacetCut;
  using MutableERC2535Service for IDiamondLoupe.Facet;

  bytes32 constant STORAGE_RANGE = type(IDiamondLoupe).interfaceId;

  function _storageRange()
  internal pure returns(bytes32 storageRange_) {
    storageRange_ = STORAGE_RANGE;
  }

//   function _setFacets(
//     IDiamondLoupe.Facet[] memory facets
//   ) internal returns(IDiamond.FacetCut[] memory facetCuts) {
//     // address executionContext = address(this);
//     facetCuts = new IDiamond.FacetCut[](facets.length);
//     // // facets._injectFacets(executionContext);
//     // address[] memory facetAddresses = new address[](facets.length);
//     // for(uint256 cursor = 0; cursor < facets.length; cursor++){
//     //   facetAddresses[cursor] = facets[cursor].facetAddress;
//     //   // facets[cursor].functionSelectors._injectFacetFunctionSelectors(facets[cursor].facetAddress, executionContext);
//     //   facets[cursor].functionSelectors._storeFuncsOfFacet(facets[cursor].facetAddress);
//     //   facetCuts[cursor] = IDiamond.FacetCut({
//     //     facetAddress: facets[cursor].facetAddress,
//     //     action: IDiamond.FacetCutAction.Add,
//     //     functionSelectors: facets[cursor].functionSelectors
//     //   });
//     //   for(uint256 cursor2 = 0; cursor2 < facets[cursor].functionSelectors.length; cursor2++) {
//     //     facets[cursor].functionSelectors[cursor2]._injectFacetofFunc(facets[cursor].facetAddress, executionContext);
//     //   }
//     // }
//     // facetAddresses._injectFacetAddresses(executionContext);

//     address[] memory facetAddresses = new address[](facets.length);
//     for(uint256 cursor = 0; cursor < facets.length; cursor++){
//       facetAddresses[cursor] = facets[cursor].facetAddress;
//       // facets[cursor].functionSelectors._injectFacetFunctionSelectors(facets[cursor].facetAddress, executionContext);
//       // facets[cursor].functionSelectors._storeFuncsOfFacet(facets[cursor].facetAddress);
//       facets[cursor]._addFacet();
//       facetCuts[cursor] = IDiamond.FacetCut({
//         facetAddress: facets[cursor].facetAddress,
//         action: IDiamond.FacetCutAction.Add,
//         functionSelectors: facets[cursor].functionSelectors
//       });
//     }
//   }

  function _processFacetCuts(
    IDiamond.FacetCut[] memory facetCuts
  ) internal {
    for(uint256 cursor = 0; cursor < facetCuts.length; cursor++) {
    //   if(facetCuts[cursor].action == IDiamond.FacetCutAction.Add ) {
    //     _addFacet(
    //       IDiamondLoupe.Facet({
    //         facetAddress: facetCuts[cursor].facetAddress,
    //         functionSelectors: facetCuts[cursor].functionSelectors
    //       })
    //     );
    //   }
    //   if(facetCuts[cursor].action == IDiamond.FacetCutAction.Replace ) {
    //     _replaceFacet(
    //       IDiamondLoupe.Facet({
    //         facetAddress: facetCuts[cursor].facetAddress,
    //         functionSelectors: facetCuts[cursor].functionSelectors
    //       })
    //     );
    //   }
    //   if(facetCuts[cursor].action == IDiamond.FacetCutAction.Remove ) {
    //     _removeFacet(
    //       IDiamondLoupe.Facet({
    //         facetAddress: facetCuts[cursor].facetAddress,
    //         functionSelectors: facetCuts[cursor].functionSelectors
    //       })
    //     );
    //   }
        facetCuts[cursor]._processFacetCut();
    }
  }

  function _processFacetCut(
    IDiamond.FacetCut memory facetCut
  ) internal {
      if(facetCut.action == IDiamond.FacetCutAction.Add ) {
        _addFacet(
          IDiamondLoupe.Facet({
            facetAddress: facetCut.facetAddress,
            functionSelectors: facetCut.functionSelectors
          })
        );
      }
      if(facetCut.action == IDiamond.FacetCutAction.Replace ) {
        _replaceFacet(
          IDiamondLoupe.Facet({
            facetAddress: facetCut.facetAddress,
            functionSelectors: facetCut.functionSelectors
          })
        );
      }
      if(facetCut.action == IDiamond.FacetCutAction.Remove ) {
        _removeFacet(
          IDiamondLoupe.Facet({
            facetAddress: facetCut.facetAddress,
            functionSelectors: facetCut.functionSelectors
          })
        );
      }
  }

  function _addFacet(
    IDiamondLoupe.Facet memory facet
  ) internal {
    _storageRange()._addFacet(facet);
    // facet.functionSelectors._calcInterfaceId()._registerInterfaceSupport();
  }

  function _replaceFacet(
    IDiamondLoupe.Facet memory facet
  ) internal {
    _storageRange()._replaceFacet(facet);
    // ERC165 state update not required because it does not care about implementation address.
  }

  function _removeFacet(
    IDiamondLoupe.Facet memory facet
  ) internal {
    _storageRange()._removeFacet(facet);
    // facet.functionSelectors._calcInterfaceId()._deregisterInterfaceSupport();
  }

  function _facets()
  internal view returns(IDiamondLoupe.Facet[] memory allFacets) {
    allFacets = _storageRange()._loadFacets();
  }

  function _facetFunctionSelectors(
    address facet
  ) internal view returns(bytes4[] memory funcsOfTarget) {
    funcsOfTarget = _storageRange()._loadFacetFunctionSelectors(facet);
  }

  function _facetAddresses()
  internal view returns(address[] memory facetAddresses) {
    facetAddresses = _storageRange()._loadFacetAddresses();
  }

  function _facetAddress(
    bytes4 func
  ) internal view returns(address facetAddress) {
    facetAddress =  _storageRange()._loadFacetAddress(func);
  }

}