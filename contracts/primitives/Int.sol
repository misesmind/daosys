// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "contracts/math/BetterMath.sol";
import "contracts/primitives/UInt.sol";

library Int {

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function _toStringSigned(
        int256 value
    ) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", UInt._toString(BetterMath._abs(value)));
    }

}