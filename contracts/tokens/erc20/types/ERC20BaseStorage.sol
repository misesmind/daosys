// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ERC20BaseStruct, ERC20BaseLayout} from "../libs/ERC20BaseLayout.sol";
import {IERC20Errors, IERC20} from "../interfaces/IERC20.sol";

abstract contract ERC20BaseStorage {

    // using Address for address;
    // using AddressSetRepo for AddressSet;
    // using BetterMath for uint256;
    // using BestestMath for uint256;
    // using BetterUniV2Service for IUniswapV2Pair; 
    // using BetterUniV2Utils for uint256;
    // using IndexedUniV2Utils for uint256;
    // using SafeERC20 for IERC20;
    // using SharesVaultUtils for uint256;
    // using UniV2MoneyMarketIndexingUtils for uint256;
    // using UniV2MoneyMarketIndexingUtils for MoneyMarketSwap;
    using ERC20BaseLayout for ERC20BaseStruct;

    address constant ERC20BaseLayout_ID =
        address(uint160(uint256(keccak256(type(ERC20BaseLayout).creationCode))));
    bytes32 constant internal ERC20BaseLayout_STORAGE_RANGE_OFFSET =
        bytes32(uint256(keccak256(abi.encode(ERC20BaseLayout_ID))) - 1);
    bytes32 internal constant ERC20BaseLayout_STORAGE_RANGE =
        type(IERC20).interfaceId;
    bytes32 internal constant ERC20BaseLayout_STORAGE_SLOT =
        ERC20BaseLayout_STORAGE_RANGE ^ ERC20BaseLayout_STORAGE_RANGE_OFFSET;
    
    function _erc20()
    internal pure virtual returns(ERC20BaseStruct storage) {
        return ERC20BaseLayout._layout(ERC20BaseLayout_STORAGE_SLOT);
    }

    /* ---------------------------------------------------------------------- */
    /*                             Initialization                             */
    /* ---------------------------------------------------------------------- */

    function _initERC20Metadata(
        string memory name_,
        string memory symbol_,
        uint8 precision_
    ) internal {
        _erc20().name = name_;
        _erc20().symbol = symbol_;
        _erc20().precision = precision_;
    }

}