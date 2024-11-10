// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/ownable/types/OwnableTarget.sol";
import "daosys/dcdi/context/erc2535/types/Facet.sol";
import "daosys/access/operatable/interface/IOperateableManager.sol";

/**
 * @title OperateableManagerFacet - Facet for Diamond proxies to expose IOperateableManager.
 * @author cyotee doge <doge.cyotee>
 */
contract OperateableManagerTarget
is
OwnableModifiers,
IOperateableManager
{


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