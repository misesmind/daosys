// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/access/ownable/types/OwnableTarget.sol";
import "daosys/context/erc2535/types/Facet.sol";
import "daosys/access/operatable/interface/IOperateableManager.sol";

/**
 * @title OperateableManagerFacet - Facet for Diamond proxies to expose IOperateableManager.
 * @author cyotee doge <doge.cyotee>
 */
contract OperateableManagerFacet
is
OwnableModifiers,
Facet,
IOperateableManager
{


    /**
     * @inheritdoc IFacet
     */    function suppoertedInterfaces()
    public view virtual override returns(bytes4[] memory interfaces) {
        interfaces =  new bytes4[](1);
        interfaces[0] = type(IOperateableManager).interfaceId;
    }

    /**
     * @inheritdoc IFacet
     */
    function facetFuncs()
    public view virtual override returns(bytes4[] memory funcs) {
        funcs = new bytes4[](1);
        funcs[0] = IOperateableManager.setOperator.selector;
    }

    /**
     * @inheritdoc IOperateableManager
     */
    function setOperator(
        IOperatable subject,
        address newOperator,
        bool approval
    ) public onlyOwner(msg.sender) returns(bool) {
        return subject.setOperator(newOperator, approval);
    }

}