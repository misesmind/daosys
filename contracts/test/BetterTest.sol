// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable no-global-import
// solhint-disable state-visibility
// solhint-disable func-name-mixedcase
// import "forge-std/Test.sol";
// import "thefactory/utils/plot/Plotter.sol";
import {
    Test,
    AddressSet,
    AddressSetRepo,
    AddressFuzzingConstraints,
    FuzzingConstraints,
    BetterFuzzing
} from "daosys/test/fuzzing/BetterFuzzing.sol";
import "daosys/test/vm/VMAware.sol";

/**
 * @dev This is an objectively better test.
 */
contract BetterTest is Test, BetterFuzzing
// , Plotter
{

    // modifier dirtiesState() {
    //     uint256 snapShot = vm.snapshotState();
    //     _;
    //     vm.revertToState(snapShot);
    // }

}