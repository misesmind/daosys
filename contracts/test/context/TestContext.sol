// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "contracts/dcdi/context/types/Context.sol";
import "contracts/test/context/ITestContext.sol";

import "contracts/test/fixtures/FixtureContextFixture.sol";

contract TestContext
is
Context
,ITestContext
,FixtureContextFixture
{

    function postDeploy()
    public virtual override(IContext, Context) returns(bool) {
        return Context.postDeploy();
    }

}