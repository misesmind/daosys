// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/test/vm/VMAware.sol";
import "daosys/networks/LOCAL.sol";
import "daosys/networks/ethereum/ETHEREUM_MAIN.sol";

import "daosys/protocols/dexes/uniswap/v2/interfaces/IUniswapV2Factory.sol";
import "daosys/protocols/dexes/uniswap/v2/interfaces/IUniswapV2Pair.sol";
import "daosys/protocols/dexes/uniswap/v2/stubs/UniV2FactoryStub.sol";
import "daosys/collections/sets/AddressSetRepo.sol";

contract UniswapV2TestFixture
is
VMAware
{

    using AddressSetRepo for AddressSet;

    IUniswapV2Factory internal _uniV2Factory;

    function uniV2Factory()
    public virtual returns(IUniswapV2Factory uniV2Factory_) {
        // Singletons, whee!
        if(address(_uniV2Factory) == address(0)) {
            // _uniV2Factory = new UniV2FactoryStub(address(this));
            // vm.label(
            //     address(_uniV2Factory),
            //     "UniV2FactoryStub"
            // );
            uint256 chainId = block.chainid;
            if(chainId == LOCAL.CHAIN_ID) {
                _uniV2Factory = new UniV2FactoryStub(address(this));
            }
            if(chainId == ETHEREUM_MAIN.CHAIN_ID) {
                _uniV2Factory = IUniswapV2Factory(ETHEREUM_MAIN.UNIV2_FACTORY);
            }
            vm.label(
                address(_uniV2Factory),
                "UniV2Factory"
            );
        }
        uniV2Factory_ = _uniV2Factory;
    }

    AddressSet internal _labeledUniV2Pools;

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
        if(!_labeledUniV2Pools._contains(address(uniV2Pool_))) {
            vm.label(
                address(uniV2Pool_),
                string.concat(
                    uniV2Pool_.symbol(),
                    " - ",
                    IERC20(uniV2Pool_.token0()).symbol(),
                    " / ",
                    IERC20(uniV2Pool_.token1()).symbol()
                )
            );
            _labeledUniV2Pools._add(address(uniV2Pool_));
        }

        return uniV2Pool_;
    }

}