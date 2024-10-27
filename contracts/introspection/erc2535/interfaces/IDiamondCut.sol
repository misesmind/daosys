// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IDiamond} from "./IDiamond.sol";

interface IDiamondCut {

    /**
     * @notice Add/replace/remove any number of functions and optionally execute a function with delegatecall
     * @param diamondCut_ Contains the facet addresses and function selectors
     * @param initTarget The address of the contract or facet to execute _calldata
     * @param initCalldata A function call, including function selector and arguments
     *  _calldata is executed with delegatecall on _init
     * @custom:emits DiamondCut
     */
    function diamondCut(
        IDiamond.FacetCut[] calldata diamondCut_,
        address initTarget,
        bytes calldata initCalldata
    ) external;

}