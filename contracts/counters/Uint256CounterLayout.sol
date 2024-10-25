// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

struct Uint256CounterStruct {
    uint256 count;
}

/**
 * @title Uint256CounterLayout - Storage layout for counting in uint256 storage operations.
 * @author mises mind <misesmind@proton.me>
 */
library Uint256CounterLayout {

    using Uint256CounterLayout for Uint256CounterStruct;

    /**
     * @dev "Binds" a struct to a storage slot.
     * @param storageRange The first slot to use in the range of slots used by the struct.
     * @return layout A struct from a Layout library bound to the provided slot.
     */
    function _layout(
        bytes32 storageRange
    ) internal pure returns(Uint256CounterStruct storage layout) {
        // storageRange ^= STORAGE_RANGE_OFFSET;
        assembly{layout.slot := storageRange}
    }

    /**
     * @param layout The struct defining the storage layout upon which to operate.
     * @return currentCount_ The current count value.
     */
    function _currentCount(
        Uint256CounterStruct storage layout
    ) internal view  returns (uint256 currentCount_) {
        currentCount_ = layout.count;
    }

    // /**
    //  * @param layout The struct defining the storage layout upon which to operate.
    //  * @return currentCount_ The current count value.
    //  */
    // function currentCount(
    //     Uint256CounterStruct storage layout
    // ) external view returns ( uint256 currentCount_ ) {
    //     currentCount_ = layout._currentCount();
    // }

    /**
     * @notice Increments the count
     * @param layout The struct defining the storage layout upon which to operate.
     * @return nextCount_ The count value after incrementing.
     */
    function _nextCount(
        Uint256CounterStruct storage layout
    ) internal returns ( uint256 nextCount_ ) {
        nextCount_ = ++layout.count;
    }

    // /**
    //  * @notice Increments the count
    //  * @param layout The struct defining the storage layout upon which to operate.
    //  * @return nextCount_ The count value after incrementing.
    //  */
    // function nextCount(
    //     Uint256CounterStruct storage layout
    // ) external returns ( uint256 nextCount_ ) {
    //     nextCount_ = layout._nextCount();
    // }

}