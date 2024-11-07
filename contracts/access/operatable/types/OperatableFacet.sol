// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/access/operatable/types/OperatableTarget.sol";
import "daosys/dcdi/context/erc2535/types/Facet.sol";
import "daosys/access/ownable/interfaces/IOwnable.sol";

/**
 * @title OperatableFacet - Facet for Diamond proxies to expose IOwnable and IOperatable.
 * @author cyotee doge <doge.cyotee>
 */
contract OperatableFacet
is
OperatableTarget,
Facet
{

    // /**
    //  * @inheritdoc IFacet
    //  */
    // function supportedInterfaces()
    // public view virtual override returns(bytes4[] memory interfaces) {
    //     interfaces =  new bytes4[](2);
    //     interfaces[0] = type(IOwnable).interfaceId;
    //     interfaces[1] = type(IOperatable).interfaceId;
    // }

    /**
     * @inheritdoc IFacet
     */
    function facetInterfaces()
    public view virtual override returns(bytes4[] memory interfaces) {
        interfaces =  new bytes4[](1);
        // interfaces[0] = type(IOwnable).interfaceId;
        interfaces[0] = type(IOperatable).interfaceId;
    }

    /**
     * @inheritdoc IFacet
     */
    function facetFuncs()
    public view virtual override returns(bytes4[] memory funcs) {
        funcs = new bytes4[](2);
        // funcs[0] = IOwnable.owner.selector;
        // funcs[1] = IOwnable.proposedOwner.selector;
        // funcs[2] = IOwnable.transferOwnership.selector;
        // funcs[3] = IOwnable.acceptOwnership.selector;
        // funcs[4] = IOwnable.renounceOwnership.selector;
        funcs[0] = IOperatable.isOperator.selector;
        funcs[1] = IOperatable.setOperator.selector;
    }

}