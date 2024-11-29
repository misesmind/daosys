// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title IOperatable - Simple function caller authorization interface.
 * @author cyotee doge <doge.cyotee>
 */
interface IOperatable {

    /**
     * @param caller Caller that failed Operator status validation.
     */
    error NotOperator(address caller);

    /**
     * @param query Address for which to query authorization as an operator.
     * @return Boolean indicating if query is authorized as an operator
     * @custom:func-sig isOperator(address)
     * @custom:func-sig-hash 6d70f7ae
     * 
     */
    function isOperator(address query)
    external view returns(bool);

    /**
     * @param func Function selector for which to query operator authorization.
     * @param query Account for which to query authorization to call `func`.
     */
    function isOperatorFor(
        bytes4 func,
        address query
    ) external view returns(bool);

    /**
     * @param newOperator Address for which to change authorization.
     * @param approval Authorization status to set for newOperator.
     * @return Gas saving boolean indicating success.
     * @custom:func-sig setOperator(address,bool)
     * @custom:func-sig-hash 558a7297
     */
    function setOperator(
        address newOperator,
        bool approval
    ) external returns(bool);

    /**
     * @param func Function selector for which to update authorization of `newOperator`.
     * @param newOperator Account for which to update authorization to call `func`.
     * @param approval Call authorization change.
     * @return Gas saving boolean indicating success.
     */
    function setOperatorFor(
        bytes4 func,
        address newOperator,
        bool approval
    ) external returns(bool);

}