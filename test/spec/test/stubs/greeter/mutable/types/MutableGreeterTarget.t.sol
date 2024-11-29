// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/test/DAOSYSTest.sol";

import "daosys/test/stubs/greeter/mutable/types/MutableGreeterTarget.sol";

contract MutableGreeterTargetTest is DAOSYSTest {

    MutableGreeterTarget greeter;

    function setUp()
    public {
        greeter = new MutableGreeterTarget();
    }

    function test_getMessage(
        string memory testMsg
    ) public {
        greeter.setMessage(testMsg);
        // TODO update to direct storage access.
        // stdstore
        //     .target(address(greeter));
        assertEq(
            keccak256(abi.encode(testMsg)),
            keccak256(abi.encode(greeter.getMessage()))
        );
    }

    function test_setMessage(
        string memory testMsg
    ) public {
        greeter.setMessage(testMsg);
        // TODO update to direct storage access.
        assertEq(
            keccak256(abi.encode(testMsg)),
            keccak256(abi.encode(greeter.getMessage()))
        );
    }

}