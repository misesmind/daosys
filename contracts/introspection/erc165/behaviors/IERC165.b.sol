// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/StdAssertions.sol";

import "daosys/collections/sets/Bytes4SetRepo.sol";

import "daosys/introspection/erc165/interfaces/IERC165.sol";

contract IERC165Behavior
is
StdAssertions
{

    using Bytes4SetRepo for Bytes4Set;

    /* ---------------------------- Expectations ---------------------------- */

    // ERC165 is query based, NOT declarative.
    // THis means there is room in the standard to validate for incorrect validation of a query.
    mapping(address subject => Bytes4Set interfaces) expected_IERC165_supportedInterfaces;

    /* ---------------------------- Declarations ---------------------------- */

    function declareExpectations_IERRC165(
        IERC165 subject,
        bytes4[] memory interfaces_
    ) public {
        expected_IERC165_supportedInterfaces
            [address(subject)]
            ._add(interfaces_);
    }

    /* ----------------------------- Validations ---------------------------- */

    function validate_IERC165_supportsInterface(IERC165 subject)
    public view {
        Bytes4Set storage interfaces = expected_IERC165_supportedInterfaces[address(subject)];
        for(uint256 cursor = 0; cursor < interfaces._length(); cursor++) {
            assertTrue(
                IERC165(address(subject)).supportsInterface(interfaces._index(cursor)),
                "Expected interface NOT supported."
            );
        }
    }

    function validate_IERC165(IERC165 subject)
    public view {
        validate_IERC165_supportsInterface(subject);
    }

}