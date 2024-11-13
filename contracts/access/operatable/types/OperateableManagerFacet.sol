// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/access/ownable/types/OwnableTarget.sol";
import "daosys/dcdi/context/erc2535/types/Facet.sol";
import "daosys/access/operatable/interface/IOperatableManager.sol";
import "daosys/access/operatable/types/OperateableManagerTarget.sol";

/**
 * @title OperateableManagerFacet - Facet for Diamond proxies to expose IOperatableManager.
 * @author cyotee doge <doge.cyotee>
 */
contract OperateableManagerFacet
is
OperateableManagerTarget,
Facet
{


    /**
     * @inheritdoc IFacet
     */    function facetInterfaces()
    public view virtual override returns(bytes4[] memory interfaces) {
        interfaces =  new bytes4[](1);
        interfaces[0] = type(IOperatableManager).interfaceId;
    }

    /**
     * @inheritdoc IFacet
     */
    function facetFuncs()
    public view virtual override returns(bytes4[] memory funcs) {
        funcs = new bytes4[](1);
        funcs[0] = IOperatableManager.setOperator.selector;
    }

    // /**
    //  * @inheritdoc IOperatableManager
    //  */
    // function setOperator(
    //     IOperatable subject,
    //     address newOperator,
    //     bool approval
    // ) public onlyOwner(msg.sender) returns(bool) {
    //     return subject.setOperator(newOperator, approval);
    // }

}