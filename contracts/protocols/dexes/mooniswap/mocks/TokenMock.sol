// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/protocols/dexes/mooniswap/access/Ownable.sol";
import "contracts/protocols/dexes/mooniswap/math/Math.sol";
import "contracts/protocols/dexes/mooniswap/math/SafeMath.sol";
import "contracts/protocols/dexes/mooniswap/erc20/ERC20.sol";
import "contracts/protocols/dexes/mooniswap/erc20/SafeERC20.sol";


contract TokenMock is ERC20, Ownable {
    uint8 decimalsMock;

    constructor(
        string memory name,
        string memory symbol,
        uint8 _decimals 
    )
        ERC20(name, symbol)
    {
        decimalsMock = _decimals;
    }

    function decimals() public view virtual override returns (uint8) {
        return decimalsMock;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}
