// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "forge-std/StdUtils.sol";

import "daosys/protocols/dexes/uniswap/v2/interfaces/IUniswapV2Pair.sol";

contract UniV2Bounds
is
StdUtils
{

    function boundUnderMaxRes(
        uint256 value,
        IUniswapV2Pair pool,
        IERC20 token
    ) public view returns(uint256) {
        return bound(
            value,
            10000,
            type(uint112).max - token.balanceOf(address(pool)) - 1
        );
    }

}