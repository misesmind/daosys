// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/tokens/erc20/interfaces/IERC20.sol";

// import {
//   IERC20
// } from "contracts/tokens/erc20/interfaces/IERC20.sol";


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
// TODO Write NatSpec comments.
// TODO Complete unit testinfg for all functions.
// TODO Implement and test external versions of all functions.
interface IMooniPair {

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  // event Transfer(address indexed from, address indexed to, uint256 value);

  // event Approval(address indexed owner, address indexed spender, uint256 value);

   /**
    * @notice return token name
    * @return tokenName token name
    */
  function name() external view returns (string memory tokenName);

  /**
   * @notice return token symbol
   * @return tokenSymbol token symbol
   */
  function symbol() external view returns (string memory tokenSymbol);

  /**
   * @notice return token decimals, generally used only for display purposes
   * @return precision token decimals
   */
  function decimals() external view returns (uint8 precision);

  /**
   * @notice query the total minted token supply
   * @return supply token supply
   */
  function totalSupply() external view returns (uint256 supply);

  /**
   * @notice query the token balance of given account
   * @param account address to query
   * @return balance token balance
   */
  function balanceOf(address account) external view returns (uint256 balance);

  /**
   * @notice query the allowance granted from given holder to given spender
   * @param holder approver of allowance
   * @param spender recipient of allowance
   * @return limit token allowance
   */
  function allowance(address holder, address spender) external view returns (uint256 limit);

  /**
   * @notice grant approval to spender to spend tokens
   * @dev prefer ERC20Extended functions to avoid transaction-ordering vulnerability (see https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729)
   * @param spender recipient of allowance
   * @param amount quantity of tokens approved for spending
   * @return success status (always true; otherwise function should revert)
   */
  function approve(address spender, uint256 amount) external returns (bool success);

  /**
   * @notice transfer tokens to given recipient
   * @param recipient beneficiary of token transfer
   * @param amount quantity of tokens to transfer
   * @return success status (always true; otherwise function should revert)
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @notice transfer tokens to given recipient on behalf of given holder
   * @param holder holder of tokens prior to transfer
   * @param recipient beneficiary of token transfer
   * @param amount quantity of tokens to transfer
   * @return success status (always true; otherwise function should revert)
   */
  function transferFrom(address holder, address recipient, uint256 amount) external returns (bool success);


  function getTokens() external view returns(IERC20[] memory);
  
  function decayPeriod() external pure returns(uint256);

    function getBalanceForAddition(IERC20 token) external view returns(uint256);

    function getBalanceForRemoval(IERC20 token) external view returns(uint256);

    function getReturn(IERC20 src, IERC20 dst, uint256 amount) external view returns(uint256);

  function deposit(
    uint256[] calldata amounts,
    uint256[] calldata minAmounts
  ) external payable returns(uint256 fairSupply);

    function depositFor(
        uint256[] calldata maxAmounts,
        uint256[] calldata minAmounts,
        address target
    )
        external
        payable
        returns (uint256 fairSupply
        // , uint256[2] memory receivedAmounts
        );

    function withdraw(uint256 amount, uint256[] memory minReturns) external;

    function swap(IERC20 src, IERC20 dst, uint256 amount, uint256 minReturn, address referral) external payable returns(uint256 result);

    function rescueFunds(IERC20 token, uint256 amount) external;

}
