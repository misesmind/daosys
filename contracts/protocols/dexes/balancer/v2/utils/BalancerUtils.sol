// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IVault, IAsset, IERC20} from "contracts/protocols/dexes/balancer/v2/interfaces/IVault.sol";
// import {IBalancerQueries} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/standalone-utils/IBalancerQueries.sol";
enum JoinKind {
    INIT,
    EXACT_TOKENS_IN_FOR_BPT_OUT,
    TOKEN_IN_FOR_EXACT_BPT_OUT,
    ALL_TOKENS_IN_FOR_EXACT_BPT_OUT
}
enum ExitKind {
    EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
    EXACT_BPT_IN_FOR_TOKENS_OUT,
    BPT_IN_FOR_EXACT_TOKENS_OUT
}
enum ExitKindComposableStable { 
    EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
    BPT_IN_FOR_EXACT_TOKENS_OUT,
    EXACT_BPT_IN_FOR_ALL_TOKENS_OUT
}
library BalancerUtils {
    struct SingleSwapBase {
        bytes32 poolId;
        address tokenIn;
        address tokenOut;
        uint256 amount;
        bytes userData;
    }
    struct BatchSwapBase {
        bytes32 poolId;
        uint256 indexTokenIn;
        uint256 indexTokenOut;
        uint256 amount;
        bytes userData;
    }

    //TODO: evaluate if it would be better have a interface instead
    // struct BalancerContracts {
    //     IVault vault;
    //     IBalancerQueries balancerQueries;
    //     IBalancerRelayer balancerRelayer;
    //     IProtocolFeePercentagesProvider protocolFeePercentagesProvider;
    // }

    //  function setValue(BalancerContracts storage data, uint _value) public {
    //     data.value = _value;
    // }

    /**
     * @dev This helper function is a fast and cheap way to convert between IERC20[] and IAsset[] types
     */
    function _convertERC20sToAssets(
        IERC20[] memory tokens
    ) internal pure returns (IAsset[] memory assets) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            assets := tokens
        }
    }

    //TODO: Change the logic so the amountIn is not the same for each token on initialzePool
    /**
     * @dev Base function for initializing a Balancer pool.
     *      This function handles the first deposit logic for a newly created balancer pool.
     * @param poolId The identifier of the Balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param maxAmountsIn The amounts to deposit on the initial liquidity deposit.
     * @param tokens The tokens from the pool to add.
     * @param fromInternalBalance To pull from our internal balance in the balancer vault or from our wallet.
     */
    function initializePool(
        bytes32 poolId,
        IVault _vault,
        uint256[] calldata maxAmountsIn,
        IERC20[] memory tokens,
        bool fromInternalBalance
    ) external {
        IAsset[] memory assets = _convertERC20sToAssets(tokens);

        // There are several ways to add liquidity and the userData field allows us to tell the pool which to use.
        // Here we're encoding data to tell the pool we're adding the initial liquidity
        // Balancer.js has several functions can help you create your userData.
        bytes memory userData = abi.encode(
            uint256(JoinKind.INIT),
            maxAmountsIn
        );

        // We need to create a JoinPoolRequest to tell the pool how we we want to add liquidity
        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest({
            assets: assets,
            maxAmountsIn: maxAmountsIn,
            userData: userData,
            fromInternalBalance: fromInternalBalance
        });

        // Here the contract that's sending the transaction must own the tokens
        address sender = address(this);
        address recipient = address(this);

        _vault.joinPool(poolId, sender, recipient, request);
    }

    /**
     * @dev Base function for depositing tokens into the Balancer pool.
     *      This internal function handles the common deposit logic for different types of deposits.
     * @param poolId The identifier of the Balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param maxAmountsIn An array of maximum token amounts for the deposit.
     * @param userData Encoded data specific to the deposit type.
     */
    function _baseDeposit(
        bytes32 poolId,
        IVault _vault,
        uint256[] memory maxAmountsIn,
        bytes memory userData
    ) internal {
        (IERC20[] memory tokens, , ) = _vault.getPoolTokens(poolId);
        IAsset[] memory assets = _convertERC20sToAssets(tokens);

        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest({
            assets: assets,
            maxAmountsIn: maxAmountsIn,
            userData: userData,
            fromInternalBalance: false
        });

        address sender = address(this);
        // address recipient = msg.sender;
        address recipient = address(this);

        _vault.joinPool(poolId, sender, recipient, request);
    }

    /**
     * @dev Deposits an exact amount of tokens into the Balancer pool in exchange for BPT (Balancer Pool Tokens).
     *      This function is for the deposit type EXACT_TOKENS_IN_FOR_BPT_OUT.
     * @param poolId The identifier of the Balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param amountsIn An array of token amounts to deposit into the pool.
     * @param minimumBPT The minimum amount of BPT tokens that the sender is willing to accept.
     */
    // TODO: Double check the arrays and userData for composable stable pools.
    function depositExactTokensInForBPTOut(
        bytes32 poolId,
        IVault _vault,
        uint256[] memory amountsIn,
        uint256 minimumBPT,
        bool isComposableStable
    ) external {
        bytes memory userData;
        if (isComposableStable) {
            // this assumes index zero is the BPT token
            uint256[] memory maxAmountsIn = new uint256[](amountsIn.length - 1);
            for (uint256 i = 0; i < amountsIn.length - 1; i++) {
                maxAmountsIn[i] = amountsIn[i + 1];
            }
            // uint256[] memory maxAmountsIn = new uint256[](amountsIn.length -1);
            // for (uint256 i = 0; i < maxAmountsIn.length -1; i++) {
            //     maxAmountsIn[i] = amountsIn[i];
            // }
            userData = abi.encode(
                JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT,
                maxAmountsIn,
                minimumBPT
            );

            _baseDeposit(poolId, _vault, amountsIn, userData);
        }
        else {
            userData = abi.encode(
                JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT,
                amountsIn,
                minimumBPT
            );

            _baseDeposit(poolId, _vault, amountsIn, userData);
        }
    }

    /**
     * @dev Deposits a single token into the Balancer pool in exchange for an exact amount of BPT.
     *      This function is for the deposit type TOKEN_IN_FOR_EXACT_BPT_OUT.
     * @param poolId The identifier of the Balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param tokenAmountIn The amount of the token to deposit.
     * @param bptAmountOut The exact amount of BPT to receive.
     * @param enterTokenIndex The index of the token being deposited in the pool's tokens array.
     */
    function depositTokenInForExactBPTOut(
        bytes32 poolId,
        IVault _vault,
        uint256 tokenAmountIn,
        uint256 bptAmountOut,
        uint256 enterTokenIndex
    ) external {
        (IERC20[] memory tokens, , ) = _vault.getPoolTokens(poolId);
        uint256[] memory maxAmountsIn = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            maxAmountsIn[i] = (i == enterTokenIndex) ? tokenAmountIn : 0;
        }

        bytes memory userData = abi.encode(
            JoinKind.TOKEN_IN_FOR_EXACT_BPT_OUT,
            bptAmountOut,
            enterTokenIndex
        );

        _baseDeposit(poolId, _vault, maxAmountsIn, userData);
    }

    /**
     * @dev Deposits all tokens in proportion into the Balancer pool in exchange for an exact amount of BPT.
     *      This function is tailored for the deposit type ALL_TOKENS_IN_FOR_EXACT_BPT_OUT.
     * @param poolId The identifier of the Balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param bptAmountOut The exact amount of BPT to receive.
     */
    function depositAllTokensInForExactBPTOut(
        bytes32 poolId,
        IVault _vault,
        uint256 bptAmountOut
    ) external {
        // Retrieve the list of tokens and their balances from the pool
        (IERC20[] memory tokens, , ) = _vault.getPoolTokens(poolId);

        // Prepare the maxAmountsIn array, indicating willingness to deposit the maximum amount of each token
        uint256[] memory maxAmountsIn = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            maxAmountsIn[i] = type(uint256).max;
        }

        // Encode userData with the join kind and the exact amount of BPT to receive
        bytes memory userData = abi.encode(
            JoinKind.ALL_TOKENS_IN_FOR_EXACT_BPT_OUT,
            bptAmountOut
        );

        // Execute the base deposit function with the prepared parameters
        _baseDeposit(poolId, _vault, maxAmountsIn, userData);
    }

    /**
     * @dev Base function for withdrawing tokens from the Balancer pool.
     *      This internal function handles the common withdrawal logic for different types of withdrawals.
     * @param poolId The identifier of the Balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param minAmountsOut An array of minimum token amounts for the withdrawal.
     * @param userData Encoded data specific to the withdrawal type.
     */
    function _baseWithdraw(
        bytes32 poolId,
        IVault _vault,
        uint256[] memory minAmountsOut,
        bytes memory userData,
        address recipient
    ) internal {
        (IERC20[] memory tokens, , ) = _vault.getPoolTokens(poolId);
        IAsset[] memory assets = _convertERC20sToAssets(tokens);

        IVault.ExitPoolRequest memory request = IVault.ExitPoolRequest({
            assets: assets,
            minAmountsOut: minAmountsOut,
            userData: userData,
            toInternalBalance: false
        });

        address sender = address(this);
        address payable recipientAddress = payable(recipient);

        _vault.exitPool(poolId, sender, recipientAddress, request);
    }
    function withdrawExactBPTInForOneTokenOut(
        bytes32 poolId,
        IVault _vault,
        uint256 tokenAmountOut,
        uint256 maxBPTAmountIn,
        uint256 exitTokenIndex,
        address recipient,
        bool isComposableStable
    ) external {
        (IERC20[] memory tokens, , ) = _vault.getPoolTokens(poolId);
        bytes memory userData;
        if (isComposableStable) {

            uint256[] memory amountsOut = new uint256[](tokens.length);
            for (uint256 i = 0; i < tokens.length; i++) {
                amountsOut[i] = (i == exitTokenIndex) ? tokenAmountOut : 0;
            }
            userData = abi.encode(
                ExitKindComposableStable.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
                maxBPTAmountIn,
                exitTokenIndex
            );

            _baseWithdraw(poolId, _vault, amountsOut, userData, recipient);

        }
        else {
            uint256[] memory amountsOut = new uint256[](tokens.length);
            for (uint256 i = 0; i < tokens.length; i++) {
                amountsOut[i] = (i == exitTokenIndex) ? tokenAmountOut : 0;
            }
            userData = abi.encode(
                ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
                maxBPTAmountIn,
                exitTokenIndex
            );

            _baseWithdraw(poolId, _vault, amountsOut, userData, recipient);
        }

    }

    function withdrawExactBPTInForTokensOut(
        bytes32 poolId,
        IVault _vault,
        uint256 bptAmountIn,
        uint256[] memory minAmountsOut,
        address recipient,
        bool isComposableStable
    ) external {
        bytes memory userData;
        if (isComposableStable) {
            userData = abi.encode(
                ExitKindComposableStable.EXACT_BPT_IN_FOR_ALL_TOKENS_OUT,
                bptAmountIn
        );
            _baseWithdraw(poolId, _vault, minAmountsOut, userData, recipient);
        }
        else {
            userData = abi.encode(
                ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT,
                bptAmountIn
            );

            _baseWithdraw(poolId, _vault, minAmountsOut, userData, recipient);
        }

    }

    function withdrawBPTInForExactTokenOut(
        bytes32 poolId,
        IVault _vault,
        uint256 tokenAmountOut,
        uint256 maxBPTAmountIn,
        uint256 exitTokenIndex,
        address recipient,
        bool isComposableStable
    ) external {
        (IERC20[] memory tokens, , ) = _vault.getPoolTokens(poolId);

        bytes memory userData;
        if (isComposableStable) {

            uint256[] memory minAmountsOut = new uint256[](tokens.length);
            for (uint256 i = 0; i < tokens.length; i++) {
                minAmountsOut[i] = (i == exitTokenIndex) ? tokenAmountOut : 0;
            }
            uint256[] memory amountsOut = new uint256[](tokens.length -1);
            for (uint256 i = 0; i < tokens.length -1; i++) {
                amountsOut[i] = tokenAmountOut;
            }
            userData = abi.encode(
                ExitKindComposableStable.BPT_IN_FOR_EXACT_TOKENS_OUT,
                amountsOut,
                maxBPTAmountIn
            );


            _baseWithdraw(poolId, _vault, minAmountsOut, userData, recipient);

        }
        else {
            uint256[] memory amountsOut = new uint256[](tokens.length);
            for (uint256 i = 0; i < tokens.length; i++) {
                amountsOut[i] = (i == exitTokenIndex) ? tokenAmountOut : 0;
            }
            userData = abi.encode(
                ExitKind.BPT_IN_FOR_EXACT_TOKENS_OUT,
                amountsOut,
                maxBPTAmountIn
            );

            _baseWithdraw(poolId, _vault, amountsOut, userData, recipient);
        }
    }

    /**
     * @dev Perform a SingleSwap on a given balancerPool.
     *      This internal function is tailored for performing single swaps on a balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param singleSwap The base structure for swapping on a balancer pool.
     * @param fundManagement The structure to indicate who's sending and receiving the funds and where its comming from.
     * @param limit The limit for the max/min of each token you're receiving or sending to balancer vault.
     * @param deadline The deadline for the swap to be executed.
     */
    function _baseSwap(
        IVault _vault,
        IVault.SingleSwap memory singleSwap,
        IVault.FundManagement memory fundManagement,
        uint256 limit,
        uint256 deadline
    ) internal returns (uint256 result) {
        result = _vault.swap(singleSwap, fundManagement, limit, deadline);
    }

    /**
     * @dev Perform a SingleSwap on a given balancerPool.
     *      This function is tailored for performing single swaps given a exact amountIN on a balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param baseSwap The initial parameters needed to formata structured swap on a balancer pool.
     * @param fundManagement The structure to indicate who's sending and receiving the funds and where its comming from.
     * @param limit The limit for the min amount of the token you're accept receiving from balancer vault given a exact amountIn.
     * @param deadline The deadline for the swap to be executed.
     */
    function swapIn(
        IVault _vault,
        SingleSwapBase memory baseSwap,
        IVault.FundManagement memory fundManagement,
        uint256 limit,
        uint256 deadline
    ) external returns (uint256 result) {
        IVault.SingleSwap memory singleSwap = IVault.SingleSwap({
            poolId: baseSwap.poolId,
            kind: IVault.SwapKind.GIVEN_IN,
            assetIn: IAsset(baseSwap.tokenIn),
            assetOut: IAsset(baseSwap.tokenOut),
            amount: baseSwap.amount,
            userData: baseSwap.userData
        });
        result = _baseSwap(_vault, singleSwap, fundManagement, limit, deadline);
    }

    /**
     * @dev Perform a SingleSwap on a given balancerPool.
     *      This function is tailored for performing single swaps given a exact amountOut on a balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param baseSwap The initial parameters needed to formata structured swap on a balancer pool.
     * @param fundManagement The structure to indicate who's sending and receiving the funds and where its comming from.
     * @param limit The limit for the max amount of the token you're accept sending from balancer vault given a exact amountOut.
     * @param deadline The deadline for the swap to be executed.
     */
    function swapOut(
        IVault _vault,
        SingleSwapBase memory baseSwap,
        IVault.FundManagement memory fundManagement,
        uint256 limit,
        uint256 deadline
    ) external returns (uint256 result) {
        IVault.SingleSwap memory singleSwap = IVault.SingleSwap({
            poolId: baseSwap.poolId,
            kind: IVault.SwapKind.GIVEN_OUT,
            assetIn: IAsset(baseSwap.tokenIn),
            assetOut: IAsset(baseSwap.tokenOut),
            amount: baseSwap.amount,
            userData: baseSwap.userData
        });
        result = _baseSwap(_vault, singleSwap, fundManagement, limit, deadline);
    }

    /**
     * @dev Perform a BatchSwap on a given balancerPool.
     *      This internal function is tailored for formatting and performing swaps on a balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param kind The kind of swap you're performing (GIVEN_IN or GIVEN_OUT).
     * @param baseSwap The base structure for swapping on a balancer pool.
     * @param fundManagement The structure to indicate who's sending and receiving the funds and where its comming from.
     * @param limits The limits for the max/min of each token you're receiving or sending to balancer vault.
     * @param deadline The deadline for the swap to be executed.
     */
    function _baseBatchSwap(
        IVault _vault,
        IVault.SwapKind kind,
        SingleSwapBase[] calldata baseSwap,
        IVault.FundManagement calldata fundManagement,
        int256[] calldata limits,
        uint256 deadline
    ) internal returns (int256[] memory) {
        IAsset[] memory assets = new IAsset[](baseSwap.length * 2);
        IVault.BatchSwapStep[] memory swaps = new IVault.BatchSwapStep[](
            baseSwap.length
        );
        for (uint96 i = 0; i < baseSwap.length; i++) {
            assets[i] = IAsset(baseSwap[i].tokenIn);
            assets[i + 1] = IAsset(baseSwap[i].tokenOut);
            swaps[i] = IVault.BatchSwapStep({
                poolId: baseSwap[i].poolId,
                assetInIndex: i,
                assetOutIndex: i + 1,
                amount: baseSwap[i].amount,
                userData: baseSwap[i].userData
            });
        }
        return
            _vault.batchSwap(
                kind,
                swaps,
                assets,
                fundManagement,
                limits,
                deadline
            );
    }

    /**
     * @dev Perform a BatchSwap on a given balancerPool.
     *      This function is tailored for formatting and performing swaps given amountsIn on a balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param baseSwap The base structure for swapping on a balancer pool.
     * @param fundManagement The structure to indicate who's sending and receiving the funds and where its comming from.
     * @param limits The limits for the max/min of each token you're receiving or sending to balancer vault.
     * @param deadline The deadline for the swap to be executed.
     */
    function batchSwapIn(
        IVault _vault,
        SingleSwapBase[] calldata baseSwap,
        IVault.FundManagement calldata fundManagement,
        int256[] calldata limits,
        uint256 deadline
    ) external returns (int256[] memory result) {
        result = _baseBatchSwap(
            _vault,
            IVault.SwapKind.GIVEN_IN,
            baseSwap,
            fundManagement,
            limits,
            deadline
        );
    }

    /**
     * @dev Perform a BatchSwap on a given balancerPool.
     *      This function is tailored for formatting and performing swaps given amountsOut on a balancer pool.
     * @param _vault The Balancer Vault contract.
     * @param baseSwap The base structure for swapping on a balancer pool.
     * @param fundManagement The structure to indicate who's sending and receiving the funds and where its comming from.
     * @param limits The limits for the max/min of each token you're receiving or sending to balancer vault.
     * @param deadline The deadline for the swap to be executed.
     */
    function batchSwapOut(
        IVault _vault,
        SingleSwapBase[] calldata baseSwap,
        IVault.FundManagement calldata fundManagement,
        int256[] calldata limits,
        uint256 deadline
    ) external returns (int256[] memory result) {
        result = _baseBatchSwap(
            _vault,
            IVault.SwapKind.GIVEN_OUT,
            baseSwap,
            fundManagement,
            limits,
            deadline
        );
    }
}
