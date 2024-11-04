// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/protocols/dexes/uniswap/v2/interfaces/IUniswapV2Factory.sol";
import "daosys/protocols/dexes/uniswap/v2/interfaces/IUniswapV2Pair.sol";
import "daosys/protocols/dexes/uniswap/v2/stubs/UniV2FactoryStub.sol";

contract UniswapV2TestFixture {

    IUniswapV2Factory internal _uniV2Factory;

    function uniV2Factory()
    public virtual returns(IUniswapV2Factory uniV2Factory_) {
        // Singletons, whee!
        if(address(_uniV2Factory) == address(0)) {
            _uniV2Factory = new UniV2FactoryStub(address(this));
        }
        uniV2Factory_ = _uniV2Factory;
    }

    function uniV2Pool(
        address tokenA,
        address tokenB
    ) public virtual returns(IUniswapV2Pair uniV2Pool_) {
        uniV2Pool_ = IUniswapV2Pair(uniV2Factory().getPair(
            tokenA,
            tokenB
        ));

        if(address(uniV2Pool_) == address(0)) {
            uniV2Pool_ = IUniswapV2Pair(uniV2Factory().createPair(
                tokenA,
                tokenB
            ));
        }

        return uniV2Pool_;
    }

}