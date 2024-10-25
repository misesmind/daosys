pragma solidity ^0.8.23;

// import {IERC20} from "contracts/tokens/erc20/interfaces/IERC20.sol";
import {IRateProvider} from "./IRateProvider.sol";
import {IBasePool} from "./IBasePool.sol";
import {IERC20} from "contracts/tokens/erc20/interfaces/IERC20.sol";

// 

interface IComposableStablePoolFactory {

    function create(
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256 amplificationParameter,
        IRateProvider[] memory rateProviders,
        uint256[] memory tokenRateCacheDurations,
        bool exemptFromYieldProtocolFeeFlag,
        uint256 swapFeePercentage,
        address owner,
        bytes32 salt
    ) external returns (IBasePool);
}