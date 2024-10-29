// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import "daosys/context/operatable/types/OperatableContext.sol";
import "daosys/dcdi/aware/types/DCDIAware.sol";
import "daosys/context/interfaces/IPrivateContext.sol";

/**
 * @title PrivateContext - Nameable OperatableContext.
 * @author cyotee doge <doge.cyotee>
 * @dev MUST be deployed from another another Context.
 */
contract PrivateContext
is
OperatableContext,
DCDIAware,
IPrivateContext
{

    /**
     * @inheritdoc IPrivateContext
     */
    string public name;

    constructor() {
        (
            address owner_,
            string memory name_
        ) = abi.decode(
            _initData(),
            (address, string)
        );
        _initOwner(owner_);
        name = name_;
    }

    
}