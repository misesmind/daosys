// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/test/DAOSYSTest.sol";
// import "daosys/access/ownable/behaviors/IOwnable.b.sol";

import "daosys/access/ownable/types/test/OwnableTargetStub.sol";

contract OwnableTargetTest
is
DAOSYSTest

{

    address owner = vm.addr(uint256(keccak256(abi.encode("owner"))));
    // address proposedOwner = vm.addr(uint256(keccak256(abi.encode("proposedOwner"))));

    OwnableTargetStub ownableStub;

    function setUp()
    public {

        declareUsed(address(owner));
        ownableStub = new OwnableTargetStub(owner);
        declareUsed(address(ownableStub));

    }

    function test_IOwnable_owner()
    public {
        assertEq(
            owner,
            ownableStub.owner()
        );
    }

    function test_IOwnable_proposedOwner(
        address proposedOwner_
    ) public
    isValid(proposedOwner_)
    {
        vm.startPrank(owner);
        ownableStub.transferOwnership(proposedOwner_);
        assertEq(
            proposedOwner_,
            ownableStub.proposedOwner()
        );
    }

    function test_IOwnable_transferOwnership(
        address proposedOwner_
    ) public
    isValid(proposedOwner_)
    {
        vm.startPrank(owner);
        vm.expectEmit(true, true, false, false, address(ownableStub));
        emit IOwnable.TransferProposed(
            proposedOwner_
        );
        ownableStub.transferOwnership(proposedOwner_);
        assertEq(
            proposedOwner_,
            ownableStub.proposedOwner()
        );
        vm.startPrank(proposedOwner_);
        vm.expectEmit(true, true, false, false, address(ownableStub));
        emit IOwnable.OwnershipTransferred(
            owner,
            proposedOwner_
        );
        ownableStub.acceptOwnership();
        assertEq(
            proposedOwner_,
            ownableStub.owner()
        );
        assertEq(
            address(0),
            ownableStub.proposedOwner()
        );
    }

}