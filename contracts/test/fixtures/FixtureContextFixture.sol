// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "contracts/test/fixtures/Fixture.sol";

import "contracts/test/fixtures/FixtureContext.sol";

contract FixtureContextFixture is Fixture {

    FixtureContext internal _fixtureContext;

    function fixtureContext()
    public returns(FixtureContext) {
        if(address(_fixtureContext) == address(0)) {
            _fixtureContext = new FixtureContext();
        }
        return _fixtureContext;
    }

    function fc()
    public returns(FixtureContext) {
        return fixtureContext();
    }

}