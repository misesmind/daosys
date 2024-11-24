// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "contracts/networks/LOCAL.sol";
import "contracts/networks/ethereum/ETHEREUM_MAIN.sol";

import "contracts/protocols/tokens/wrappers/weth/9/types/WETH9.sol";

contract WETH9Fixture {

    IWETH internal _weth9;

    function weth9()
    public returns(IWETH) {
        if(address(_weth9) == address(0)) {
            uint256 chainId = block.chainid;
            if(chainId == LOCAL.CHAIN_ID) {
                _weth9 = new WETH9();
            }
            if(chainId == ETHEREUM_MAIN.CHAIN_ID) {
                _weth9 = IWETH(ETHEREUM_MAIN.WETH9);
            }
        }
        // _weth9 = new WETH9();
        return _weth9;
    }
}