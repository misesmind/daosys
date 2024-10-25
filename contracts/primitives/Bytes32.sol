// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Bytes32 - Standardized operations for bytes32.
 * @author mises mind <misesmind@proton.me>
 */
library Bytes32 {

    // TODO Could it be possible to calculate and store this immutably on creation?
    // Proxies will be DELEGATECALLING targets.
    // Targets couldn't store this.
    // Maybe proxies can caculate and store their obfuscation value?
    // Viable to reserve slot 0 for this?
    // FML for having to deal with this.
    // Why do humans have to suck sometimes?
    function _scramble(
        bytes32 value
    ) internal view returns(bytes32) {
        return value ^ bytes32((uint256(keccak256(abi.encodePacked(address(this)))) - 1));
    }

    /**
     * @dev Converts an bytes32 to an address truncating from the left.
     * @dev All values over 2^160-1 will be returned as 2^160-1.
     * @param value The value to convert.
     * @return result The converted value.
     */
    function _toAddress(
        bytes32 value
    ) internal pure returns(address result)  {
        //               address(bytes20(value)) is NOT equivalent.
        result = address(uint160(uint256(value)));
    }
  
}