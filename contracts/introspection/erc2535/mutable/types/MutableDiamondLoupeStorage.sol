// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import {
    IDiamondLoupe
} from "daosys/introspection/erc2535/interfaces/IDiamondLoupe.sol";
import "daosys/introspection/erc2535/interfaces/IDiamond.sol";
import {
    ERC165Utils,
    MutableERC165Storage
} from "daosys/introspection/erc165/mutable/types/MutableERC165Storage.sol";
import "daosys/introspection/erc2535/mutable/libs/MutableERC2535Layout.sol";
import "daosys/primitives/UInt.sol";

abstract contract MutableDiamondLoupeStorage is MutableERC165Storage {

    using AddressSetRepo for AddressSet;
    using Bytes4SetRepo for Bytes4Set;
    using ERC165Utils for bytes4[];
    using FacetSetLayout for FacetSetLayout.Struct;
    using MutableERC2535Layout for MutableERC253Struct;
    using UInt for uint256;
    // using MutableERC2535Service for bytes4;
    // using MutableERC2535Service for IDiamond.FacetCut;
    // using MutableERC2535Service for IDiamond.FacetCut[];
    // using MutableERC2535Service for IDiamondLoupe.Facet;

    address constant MutableERC2535Layout_ID =
        address(uint160(uint256(keccak256(type(MutableERC2535Layout).creationCode))));
    bytes32 constant internal MutableERC2535Layout_STORAGE_RANGE_OFFSET =
        bytes32(uint256(keccak256(abi.encode(MutableERC2535Layout_ID))) - 1);
    bytes32 internal constant MutableERC2535Layout_STORAGE_RANGE =
        type(IDiamondLoupe).interfaceId;
    bytes32 internal constant MutableERC2535Layout_STORAGE_SLOT =
        MutableERC2535Layout_STORAGE_RANGE ^ MutableERC2535Layout_STORAGE_RANGE_OFFSET;

    function _loupe()
    internal pure virtual returns(MutableERC253Struct storage) {
        return MutableERC2535Layout._layout(MutableERC2535Layout_STORAGE_SLOT);
    }

    function _processFacetCuts(
        IDiamond.FacetCut[] memory facetCuts
    ) internal {
        // facetCuts._processFacetCuts();
        for(uint256 cursor = 0; cursor < facetCuts.length; cursor++) {
            _processFacetCut(facetCuts[cursor]);
        }
    }

    function _processFacetCut(
        IDiamond.FacetCut memory facetCut
    ) internal {
        // facetCut._processFacetCut();
        if(facetCut.facetAddress == address(0)) {
            return;
        } else {
            // Y u no switch?
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
    }

    function _addFacet(
        IDiamondLoupe.Facet memory facet
    ) internal {
        for(uint256 cursor = 0; cursor < facet.functionSelectors.length; cursor++) {
            /*
            If the action is Add, update the function selector mapping for each functionSelectors item to the facetAddress.
            If any of the functionSelectors had a mapped facet, revert instead.
            */
            require(
                _loupe().facetAddress[facet.functionSelectors[cursor]] == address(0),
                string.concat(
                    "Function ",
                    cursor._toString(),
                    " previously set."
                )
            );
            _loupe().facetAddress[facet.functionSelectors[cursor]] = facet.facetAddress;
        }
        // layout._storeFacet(facet);
        _loupe().facets._add(facet);
        _loupe().facetFunctionSelectors[facet.facetAddress]._add(facet.functionSelectors);
        _loupe().facetAddresses._add(facet.facetAddress);
    }

    function _replaceFacet(
        IDiamondLoupe.Facet memory facet
    ) internal {
        // facet._replaceFacet();
        // ERC165 state update not required because it does not care about implementation address.
        // MutableERC2535Layout.Struct storage layout = storageRange._layout();
        for(uint256 cursor = 0; cursor < facet.functionSelectors.length; cursor++) {
            /*
            If the action is Replace, update the function selector mapping for each functionSelectors item to the facetAddress.
            If any of the functionSelectors had a value equal to facetAddress or the selector was unset, revert instead.
            */
            require(
                _loupe().facetAddress[facet.functionSelectors[cursor]] != address(0)
                ||
                _loupe().facetAddress[facet.functionSelectors[cursor]] != facet.facetAddress,
                "Function not previously set or redundant."
            );

            address currentFacet = _loupe().facetAddress[facet.functionSelectors[cursor]];
            _loupe().facetFunctionSelectors[currentFacet]._remove(facet.functionSelectors[cursor]);
            if(_loupe().facetFunctionSelectors[currentFacet]._length() == 0) {
                _loupe().facets._remove(facet.facetAddress);
                _loupe().facetAddresses._remove(facet.facetAddress);
            }
            
            _loupe().facetAddress[facet.functionSelectors[cursor]] = facet.facetAddress;
        }
        _loupe().facets._add(facet);
        _loupe().facetFunctionSelectors[facet.facetAddress]._add(facet.functionSelectors);
        _loupe().facetAddresses._add(facet.facetAddress);
    }

    function _removeFacet(
        IDiamondLoupe.Facet memory facet
    ) internal {
        // facet._removeFacet();
        // MutableERC2535Layout.Struct storage layout = storageRange._layout();
        for(uint256 cursor = 0; cursor < facet.functionSelectors.length; cursor++) {
            /*
            If the action is Remove, remove the function selector mapping for each functionSelectors item.
            If any of the functionSelectors were previously unset, revert instead.
            */
            require(
                _loupe().facetAddress[facet.functionSelectors[cursor]] != address(0),
                "Function not previously set."
            );
            _loupe().facetAddress[facet.functionSelectors[cursor]] = facet.facetAddress;
        }
        // layout._removeFacet(facet);
        _loupe().facets._remove(facet.facetAddress);
        // Does not actually delete values, just unmaps storage pointer.
        delete _loupe().facetFunctionSelectors[facet.facetAddress];
        _loupe().facetAddresses._remove(facet.facetAddress);
    }

    /**
     * @notice Gets all facet addresses and their four byte function selectors.
     * @return facets_ Facet
     */
    function _facets() internal view returns (IDiamondLoupe.Facet[] memory facets_) {
        // facets_ = MutableERC2535Service._facets();
        return _loupe().facets._setAsArray();
    }

    /**
     * @notice Gets all the function selectors supported by a specific facet.
     * @param facetAddress The facet address.
     * @return facetFunctionSelectors_
     */
    function _facetFunctionSelectors(
        address facetAddress
    ) internal view returns (bytes4[] memory facetFunctionSelectors_) {
        // facetFunctionSelectors_ = MutableERC2535Service._facetFunctionSelectors(_facet);
        return _loupe().facetFunctionSelectors[facetAddress]._asArray();
    }

    /**
     * @notice Get all the facet addresses used by a diamond.
     * @return facetAddresses_
     */
    function _facetAddresses()
    internal view returns (address[] memory facetAddresses_) {
        // facetAddresses_ = MutableERC2535Service._facetAddresses();
        return _loupe().facetAddresses._asArray();
    }

    /**
     * @notice Gets the facet that supports the given selector.
     * @dev If facet is not found return address(0).
     * @param _functionSelector The function selector.
     * @return facetAddress_ The facet address.
     */
    function _facetAddress(
        bytes4 _functionSelector
    ) internal view virtual returns (address facetAddress_) {
        // facetAddress_ = _functionSelector._facetAddress();
        return _loupe().facetAddress[_functionSelector];
    }

}