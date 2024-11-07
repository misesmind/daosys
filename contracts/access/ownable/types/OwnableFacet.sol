// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/ownable/types/OwnableTarget.sol";
import "daosys/dcdi/context/erc2535/types/Facet.sol";
import "daosys/dcdi/aware/types/DCDIAware.sol";
import "daosys/introspection/erc165/mutable/types/MutableERC165Target.sol";

contract OwnableFacet
is
OwnableTarget,
MutableERC165Target,
Facet,
DCDIAware
{

    constructor() {
        _initERC165(supportedInterfaces());
    }

    function supportedInterfaces()
    public view virtual
    // override
    returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](3);
        interfaces[0] = type(IERC165).interfaceId;
        interfaces[1] = type(IDCDI).interfaceId;
        interfaces[2] = type(IFacet).interfaceId;
    }

    /**
     * @inheritdoc IFacet
     */
    function facetInterfaces()
    public view virtual override returns(bytes4[] memory interfaces) {
        interfaces =  new bytes4[](1);
        interfaces[0] = type(IOwnable).interfaceId;
    }

    /**
     * @inheritdoc IFacet
     */
    function facetFuncs()
    public view virtual override returns(bytes4[] memory funcs) {
        funcs = new bytes4[](5);
        funcs[0] = IOwnable.owner.selector;
        funcs[1] = IOwnable.proposedOwner.selector;
        funcs[2] = IOwnable.transferOwnership.selector;
        funcs[3] = IOwnable.acceptOwnership.selector;
        funcs[4] = IOwnable.renounceOwnership.selector;
    }

}