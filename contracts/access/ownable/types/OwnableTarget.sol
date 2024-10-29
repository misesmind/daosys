// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/ownable/types/OwnableModifiers.sol";
import {IOwnable} from "daosys/access/ownable/interfaces/IOwnable.sol";

/**
 * @title OwnableTarget - Contract exposing IOwnable.
 * @author cyotee doge <doge.cyotee>
 */
contract OwnableTarget is OwnableModifiers, IOwnable {

    /**
     * @inheritdoc IOwnable
     */
    function owner()
    public view returns(address) {
        return _owner();
    }

    /**
     * @inheritdoc IOwnable
     */
    function proposedOwner()
    public view returns(address) {
        return _proposedOwner();
    }

    /**
     * @inheritdoc IOwnable
     */
    function transferOwnership(address proposedOwner_)
    public onlyOwner(msg.sender) returns(bool) {
        return _transferOwnerShip(proposedOwner_);
    }

    /**
     * @inheritdoc IOwnable
     */
    function acceptOwnership()
    public onlyProposedOwner(msg.sender) returns(bool) {
        return _acceptOwnership();
    }

    /**
     * @inheritdoc IOwnable
     */
    function renounceOwnership()
    public onlyOwner(msg.sender) returns(bool) {
        return _renounceOwnership();
    }

}