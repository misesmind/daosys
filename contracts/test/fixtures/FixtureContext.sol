// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "contracts/test/fixtures/IFixtureContext.sol";

import "contracts/protocols/tokens/wrappers/weth/9/fixtures/WETH9Fixture.sol";

contract FixtureContext is IFixtureContext {

    WETH9Fixture internal _weth9Fixture;

    function weth9Fixture()
    public returns(WETH9Fixture) {
        if(address(_weth9Fixture) == address(0)) {
            _weth9Fixture = new WETH9Fixture();
        }
        return _weth9Fixture;
    }
    
}