// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/test/vm/VMAware.sol";

/* -------------------------------- Fixtures -------------------------------- */

import "daosys/dcdi/context/fixtures/Context.f.sol";

/* -------------------------------- Behaviors ------------------------------- */

import "daosys/dcdi/aware/behaviors/IDCDI.b.sol";

contract ContextTestFixture
is
VMAware,
/* Fixtures */
ContextFixture,
/* Behaviors */
IDCDIBehavior
{

    function setUp() public virtual {
        vm.label(address(context()), "Context");
    }

}