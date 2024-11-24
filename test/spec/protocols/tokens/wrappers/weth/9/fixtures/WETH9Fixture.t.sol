// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/test/DAOSYSTest.sol";

import "daosys/networks/ethereum/ETHEREUM_MAIN.sol";

contract WETH9FixtureTest is DAOSYSTest {

    function setUp()
    public {

    }

    function test_WETH9_LOCAL_NET()
    public
    {
        console.log(block.chainid);
        assertNotEq(
            address(ETHEREUM_MAIN.WETH9),
            address(tc().fc().weth9Fixture().weth9())
        );
        assertNotEq(
            address(9),
            address(tc().fc().weth9Fixture().weth9())
        );
    }

    function test_WETH9_ETHEREUM_MAIN_NET()
    public
    fork("mainnet_infura", 19862653)
    {
        console.log(block.chainid);
        assertEq(
            address(ETHEREUM_MAIN.WETH9),
            address(tc().fc().weth9Fixture().weth9())
        );
    }

}