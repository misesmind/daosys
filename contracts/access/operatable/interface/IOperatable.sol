// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @title IOperatable - Simple function authorization interface.
 * @author cyotee doge
 */
interface IOperatable {

    /**
     * @param query Addres for which to query authorization as an operator.
     * @return Boolean indicating if query is authorrized as an operator
     * @custom:func-sig isOperator(address)
     * @custom:func-sig-hsh 6d70f7ae
     * 
     */
    function isOperator(address query)
    external view returns(bool);

    /**
     * @param newOperator Addrees for which to change authorization.
     * @param approval Authorization status to set for newOperator.
     * @return Boolean indicating success.
     */
    function setOperator(address newOperator, bool approval)
    external returns(bool);

}