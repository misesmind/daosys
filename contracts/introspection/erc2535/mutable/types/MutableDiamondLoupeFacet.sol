// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/introspection/erc2535/mutable/types/MutableDiamondLoupeTarget.sol";
import "daosys/introspection/erc165/mutable/types/MutableERC165Target.sol";
import "daosys/context/erc2535/types/Facet.sol";
import "daosys/dcdi/aware/types/DCDIAware.sol";

contract MutableDiamondLoupeFacet
is
MutableERC165Target, 
MutableDiamondLoupeTarget,
DCDIAware,
Facet
{
    constructor() {
        _initERC165(supportedInterfaces());
    }

    function supportedInterfaces()
    public view virtual
    // override
    returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](3);
        interfaces[0] = type(IDCDI).interfaceId;
        interfaces[1] = type(IERC165).interfaceId;
        interfaces[2] = type(IFacet).interfaceId;
    }

    function facetInterfaces()
    public view virtual
    override
    returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](2);
        interfaces[0] = type(IERC165).interfaceId;
        interfaces[1] = type(IDiamondLoupe).interfaceId;
    }

    function facetFuncs()
    public pure virtual
    override returns(bytes4[] memory funcs) {
        funcs = new bytes4[](5);
        funcs[0] = IERC165.supportsInterface.selector;
        funcs[1] = IDiamondLoupe.facets.selector;
        funcs[2] = IDiamondLoupe.facetFunctionSelectors.selector;
        funcs[3] = IDiamondLoupe.facetAddresses.selector;
        funcs[4] = IDiamondLoupe.facetAddress.selector;
    }

}