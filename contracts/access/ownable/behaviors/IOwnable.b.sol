// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "contracts/test/behavior/Behavior.sol";

import "contracts/access/ownable/interfaces/IOwnable.sol";
// import "contracts/access/ownable/behaviors/IOwnable.e.sol";

contract IOwnableBehavior
is
// IOwnableExpectations
Behavior
{

    // mapping(IOwnable subject => address owner) public expected_owner;

    // mapping(IOwnable subject => address proposedOwner) public expected_proposedOwner;

    // function expect_IOwnable_owner(
    //     IOwnable subject,
    //     address owner
    // ) public {
    //     expected_owner[subject] = owner;
    // }

    // function expect_IOwnable_proposedOwner(
    //     IOwnable subject,
    //     address proposedOwner
    // ) public {
    //     expected_proposedOwner[subject] = proposedOwner;
    // }

    // function validate_IOwnable_owner(
    //     IOwnable subject
    // ) public view {
    //     assertEq(
    //         expected_owner[subject],
    //         subject.owner()
    //     );

    // }

}