// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/ownable/types/OwnableTarget.sol";
import "daosys/dcdi/context/erc2535/types/Facet.sol";
import "daosys/access/operatable/interface/IOperatableManager.sol";

/**
 * @title OperatableManagerFacet - Facet for Diamond proxies to expose IOperatableManager.
 * @author cyotee doge <doge.cyotee>
 */
contract OperatableManagerTarget
is
OwnableModifiers,
IOperatableManager
{


    /**
     * @inheritdoc IOperatableManager
     */
    function setOperator(
        IOperatable subject,
        address newOperator,
        bool approval
    ) public onlyOwner(msg.sender) returns(bool) {
        return subject.setOperator(newOperator, approval);
    }

    function setOperatorFor(
        IOperatable subject,
        bytes4 func, 
        address newOperator,
        bool approval
    ) public onlyOwner(msg.sender) returns(bool) {
        return subject.setOperatorFor(func, newOperator, approval);
    }

}