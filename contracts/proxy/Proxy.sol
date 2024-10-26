// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// solhint-disable no-complex-fallback
// solhint-disable no-empty-blocks
// solhint-disable reason-string
// solhint-disable no-inline-assembly
// import {Address} from "contracts/libs/primitives/Address.sol";
import {Address} from "daosys/primitives/Address.sol";

/**
 * @title Base proxy contract
 */
// TODO Write NatSpec comments.
// TODO Complete unit testing for all functions.
abstract contract Proxy {

    using Address for address;

    /**
     * @notice delegate all calls to implementation contract
     * @dev reverts if implementation address contains no code, for compatibility with metamorphic contracts
     * @dev memory location in use by assembly may be unsafe in other contexts
     */
    // TODO Define all Consider as SPIKE once Anchor config is updated.
    // TODO Consider reverting if msg.sender is address(0).
    fallback() external payable {

        // Reject all transactions originating from address(0);
        require(
            msg.sender != address(0),
            "address(0) is never valid"
        );

        address target = _getTarget();

        // Leveraged by security sub-system to revert TX by providing address(0) as target so this check will revert.
        require(
            target._isContract(),
            "Proxy: implementation must be contract"
        );

        assembly {
        calldatacopy(0, 0, calldatasize())
        let result := delegatecall(
            gas(),
            target,
            0,
            calldatasize(),
            0,
            0
        )
        returndatacopy(0, 0, returndatasize())

        switch result
            case 0 {
            revert(0, returndatasize())
            }
            default {
            return(0, returndatasize())
            }
        }
    }

    receive() external payable {}

    /**
     * @notice get logic implementation address
     * @return target_ DELEGATECALL address target
     */
    function _getTarget()
    internal virtual returns (address target_);
  
}