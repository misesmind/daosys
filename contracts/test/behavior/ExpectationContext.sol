// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "contracts/test/behavior/IExpectation.sol";

contract ExpectationContext {

    mapping(bytes4 interfaceId => IExpectation expectation) public expectationOfId;

    function registerExpectation(
        bytes4 interfaceId,
        IExpectation expectation
    ) public returns(bool) {
        expectationOfId[interfaceId] = expectation;
        return true;
    }

}