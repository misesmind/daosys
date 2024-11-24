// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "contracts/test/fixtures/Fixture.sol";
import "contracts/test/context/TestContext.sol";
import "contracts/test/context/ITestContext.sol";

contract TestContextFixture is Fixture {

    TestContext internal _testContext;

    function testContext()
    public returns(TestContext) {
        if(address(_testContext) == address(0)) {
            _testContext = new TestContext();
        }
        return _testContext;
    }

    function tc()
    public returns(TestContext) {
        return testContext();
    }

}