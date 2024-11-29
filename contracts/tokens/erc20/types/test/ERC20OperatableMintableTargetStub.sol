// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {
    IERC20Errors,
    IERC20,
    ERC20Storage,
    ERC20Target,
    ERC20MintableTarget,
    IERC20OperatableMintable,
    ERC20OperatableMintableTarget
} from "daosys/tokens/erc20/types/ERC20OperatableMintableTarget.sol";
// import "contracts/tokens/erc20/interfaces/IERC20OperatableMintable.sol";

contract ERC20OperatableMintableTargetStub is ERC20OperatableMintableTarget {

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 newTokenSupply,
        address owner_
    ) {
        _initERC20(
            tokenName,
            tokenSymbol,
            tokenDecimals
        );
        _mint(newTokenSupply, owner_);
        _initOwner(owner_);
        _isOperator(owner_, true);
    }

}