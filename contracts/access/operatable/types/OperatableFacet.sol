// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/access/operatable/types/OperatableTarget.sol";
import "daosys/context/erc2535/types/Facet.sol";
import "daosys/access/ownable/interfaces/IOwnable.sol";

contract OperatableFacet
is
OperatableTarget,
Facet
{

    function suppoertedInterfaces()
    public view virtual override returns(bytes4[] memory interfaces) {
        interfaces =  new bytes4[](2);
        interfaces[0] = type(IOwnable).interfaceId;
        interfaces[1] = type(IOperatable).interfaceId;
    }

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