// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/introspection/erc2535/interfaces/IDiamond.sol";
import "daosys/introspection/erc2535/interfaces/IDiamondCut.sol";
import "daosys/introspection/erc2535/mutable/types/MutableDiamondLoupeStorage.sol";
import "daosys/primitives/Address.sol";

contract MutableDiamondCutTarget
is
IDiamond,
IDiamondCut,
MutableDiamondLoupeStorage
{

    using Address for address;
    /* -------------------------------------------------------------------------- */
    /*                                    LOGIC                                   */
    /* -------------------------------------------------------------------------- */

    function _diamondCut(
        IDiamond.FacetCut[] memory diamondCut_,
        address initTarget,
        bytes memory initCalldata
    ) internal {
        _processFacetCut(diamondCut_);
        // bytes memory returnData
        if(initCalldata.length > 0 && initTarget != address(0)) {
            // (bool result, ) = initTarget.delegatecall(initCalldata);
            // require(result == true, "Address:_delegateCall:: delegatecall failed");
            initTarget._delegateCall(initCalldata);
        }
        emit DiamondCut(
            diamondCut_,
            initTarget,
            initCalldata
        );
    }

    function diamondCut(
        IDiamond.FacetCut[] calldata diamondCut_,
        address initTarget,
        bytes calldata initCalldata
    ) external {
        _diamondCut(
            diamondCut_,
            initTarget,
            initCalldata
        );
    }

}