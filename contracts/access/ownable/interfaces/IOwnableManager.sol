// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/access/ownable/interfaces/IOwnable.sol";

/**
 * @title IOwnableManager - Interface for managing contract ownerrship via a owning contract.
 * @author cyotee doge <doge.cyotee>
 */
interface IOwnableManager {

    /**
     * @param subject Subject of ownership for which to transfer wonership.
     * @param proposedOwner_ Address to propose for ownership transfer pending acceptance.
     * @return Boolean indicating succesful ownership transfer proposal.
     */
    function transferOwnershipFor(
        IOwnable subject,
        address proposedOwner_
    ) external returns(bool);

    /**
     * @param subject Subject of ownership for which to accept a proposed ownership transfer.
     * @return Boolean indicating success acceptance of a proposed ownership transfer.
     */
    function acceptOwnershipFor(IOwnable subject) external returns(bool);

    /**
     * @param subject Subject og ownership for which to renounce wonershop by transfering to address(0);
     * @return Boolean indicating successful renouncement.
     */
    function renounceOwnershipFor(IOwnable subject) external returns(bool);

}