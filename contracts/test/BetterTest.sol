// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable no-global-import
// solhint-disable state-visibility
// solhint-disable func-name-mixedcase
// import "thefactory/utils/plot/Plotter.sol";

// import "forge-std/Test.sol";
// import "daosys/Constants.sol";
import {
    Test,
    AddressSet,
    AddressSetRepo,
    AddressFuzzingConstraints,
    FuzzingConstraints,
    BetterFuzzing
} from "daosys/test/fuzzing/BetterFuzzing.sol";
import "contracts/test/forking/BetterForking.sol";
import "daosys/test/vm/VMAware.sol";
import "daosys/protocols/dexes/uniswap/v2/libs/BetterUniV2Utils.sol";

/**
 * @title BetterTest - An objectively better test.
 * @author cyotee doge <doge.cyotee>
 * @dev This is an objectively better test.
 */
contract BetterTest
is
// Be a drop-in replacement for objectively worse tests.
Test
,BetterForking
// Be better fuzzing.
,BetterFuzzing
// , Plotter
{

    VmSafe.Wallet internal _marketWallet = vm.createWallet("market");

    function marketWallet()
    public view returns(VmSafe.Wallet memory) {
        return _marketWallet;
    }

    function market()
    public view returns(address) {
        return marketWallet().addr;
    }

    // modifier fork(
    //     string memory networkName,
    //     uint256 blockNumber
    // ) {
    //     vm.createSelectFork(networkName, blockNumber);
    //     _;
    // }

    // function assertEq(
    //     string memory expected,
    //     string memory value
    // ) public pure {
    //     assertEq(
    //         expected,
    //         value
    //     );
    // }

}