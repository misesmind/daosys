// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/introspection/erc165/mutable/types/MutableERC165Target.sol";
import "daosys/dcdi/context/erc2535/types/Facet.sol";

contract MutableERC165Facet
is MutableERC165Target, Facet {

    function facetInterfaces()
    public view virtual
    override
    returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](1);
        interfaces[0] = type(IERC165).interfaceId;
    }

    function facetFuncs()
    public pure virtual
    override returns(bytes4[] memory funcs) {
        funcs = new bytes4[](11);
        funcs[0] = IERC165.supportsInterface.selector;
    }

}