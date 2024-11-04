// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Base.sol";

contract VMAware
is
CommonBase
{

    modifier dirtiesState() {
        uint256 snapShot = vm.snapshotState();
        _;
        vm.revertToState(snapShot);
    }

}