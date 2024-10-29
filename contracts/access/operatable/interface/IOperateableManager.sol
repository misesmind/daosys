// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/access/operatable/interface/IOperatable.sol";

/**
 * @title IOperateableManager - Interface for managing operator authoritzation of contracts owned by contracts.
 * @author cyotee doge <doge.cyotee>
 */
interface IOperateableManager {

    /**
     * @param subject Subject of onwership for which to change the authorization status of newOperator.
     * @param newOperator Address to authorize for function calls.
     */
    function setOperator(
        IOperatable subject,
        address newOperator,
        bool approval
    ) external returns(bool);

}
