// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "daosys/test/vm/VMAware.sol";

/**
 * @title BetterForking - Objectively better chain state forking.
 * @author cyotee doge <doge.cyotee>
 * @dev Aids in interleaving chain state forking with tests.
 */
contract BetterForking
is
VMAware
{

    modifier fork(
        string memory networkName,
        uint256 blockNumber
    ) {
        vm.createSelectFork(networkName, blockNumber);
        // fork(networkName, blockNumber);
        _;
    }

    // function fork(
    //     string memory networkName,
    //     uint256 blockNumber
    // ) public {
    //     vm.createSelectFork(networkName, blockNumber);
    // }

}