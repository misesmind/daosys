// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {
    IERC20Errors,
    IERC20,
    IERC20Mintable
} from "./IERC20Mintable.sol";
import {IOperatable} from "contracts/access/operatable/interface/IOperatable.sol";

interface IERC20OperatableMintable is IERC20Mintable, IOperatable {

    function mint(
        uint256 amount,
        address to
    ) external payable returns(uint256);

    function burn(
        uint256 amount,
        address to
    ) external returns(uint256);

    function isOperator(address query)
    external view returns(bool);

    function setOperator(
        address operator,
        bool status
    ) external returns(bool);
    
}