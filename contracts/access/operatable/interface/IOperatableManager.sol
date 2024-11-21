// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/operatable/interface/IOperatable.sol";

/**
 * @title IOperatableManager - Interface for managing operator authoritzation of contracts owned by contracts.
 * @author cyotee doge <doge.cyotee>
 */
interface IOperatableManager {

    /**
     * @param subject Subject of onwership for which to change the authorization status of newOperator.
     * @param newOperator Address to authorize for function calls.
     */
    function setOperator(
        IOperatable subject,
        address newOperator,
        bool approval
    ) external returns(bool);

    function setOperatorFor(
        IOperatable subject,
        bytes4 func, 
        address newOperator,
        bool approval
    ) external returns(bool);

}
