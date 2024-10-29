// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/**
 * @title IPrivateContext - Nameable OperatableContext interface.
 * @author cyotee doge <doge.cyotee>
 */
interface IPrivateContext {

    /**
     * @return Assigned name as human readable identifier.
     */
    function name()
    external view returns(string memory);

}