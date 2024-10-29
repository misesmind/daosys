// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/ownable/types/OwnableStorage.sol";

/**
 * @title OwnableModifiers - Inheirtable modifiers for ownership status validation.
 * @author cyotee doge <doge.cyotee>
 * @notice Modifiers accept arguments to allow application to any variable.
 */
contract OwnableModifiers is OwnableStorage {

    /**
     * @notice Reverts if challenger is NOT owner.
     * @param challenger Address to validate as owner.
     */
    modifier onlyOwner(address challenger) {
        _ifNotOwner(challenger);
        _;
    }
    
    /**
     * @notice Reverts if challenger is NOT proposed for ownership.
     * @param challenger Address to validate for ownership proposal.
     */
    modifier onlyProposedOwner(address challenger) {
        _ifNotProposedOwner(challenger);
        _;
    }

}