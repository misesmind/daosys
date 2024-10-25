// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @title IOwnable "Owned" contract management and inspection interface.
 * @author mises mind <misesmind@proton.me>
 */
interface IOwnable {

    error NotOwner(address caller);

    error NotProposed(address caller);

    // event TransferProposed();

    event TransferProposed(address indexed proposedOwner);

    event OwnershipTransfered(
        address indexed prevOwner,
        address indexed newOwner
    );

    /**
     * @return The address of the owner of this contract instance.
     */
    function owner() external view returns(address);

    /**
     * @return The address of the owner proposed for transfer.
     */
    function proposedOwner() external view returns(address);

    /**
     * @param proposedOwner_ The address to propose for transfering ownership.
     * @return Boolean indicating domain logic success.
     */
    function transferOwnership(address proposedOwner_) external returns(bool);

    /**
     * @notice Allows the proposed owner to accept ownership transfer.
     * @return Boolean indicating domain logic success.
     */
    function acceptOwnership() external returns(bool);

    /**
     * @notice Allows the owner to remove ownership claim without treansfer.
     * @notice Reverts if a proposed owner is set to other than address(0);
     * @return Boolean indicating domain logic success.
     */
    function renounceOwnership() external returns(bool);

}