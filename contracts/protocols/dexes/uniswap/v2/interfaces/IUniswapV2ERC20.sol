// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    IERC20Errors,
    IERC20
} from "contracts/tokens/erc20/interfaces/IERC20.sol";
import {IERC2612} from "contracts/access/erc2612/interfaces/IERC2612.sol";

interface IUniswapV2ERC20 is IERC20, IERC2612 {

    // function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    // function nonces(address owner) external view returns (uint);

    // function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}
