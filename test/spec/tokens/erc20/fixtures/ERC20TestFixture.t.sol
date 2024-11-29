// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// // import "hardhat/console.sol";
// import "forge-std/console.sol";
// // import "forge-std/console2.sol";

import "daosys/test/BetterTest.sol";

import "daosys/tokens/erc20/fixtures/ERC20Test.f.sol";

contract ERC20TestFixtureTest
is
BetterTest
,ERC20TestFixture
{

    function setUp()
    public virtual override {
        super.setUp();
    }

    function test() public {
        // IERC20OperatableMintable token = erc20Stub();
        IERC20OperatableMintable token = erc20Stub(
            context(),
            diamondIniter(),
            0,
            address(this),
            "",
            "",
            0,
            0
        );
        console.log(
            "token symbol = %s",
            token.symbol()
        );
    }

}