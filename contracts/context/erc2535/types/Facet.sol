// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/context/erc2535/interfaces/IFacet.sol";

abstract contract Facet is IFacet {

    function facetFuncs()
    public view virtual returns(bytes4[] memory funcs);

}