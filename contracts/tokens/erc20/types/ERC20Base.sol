// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import {
//     IERC20Errors,
//     IERC20
// } from "contracts/tokens/erc20/interfaces/IERC20.sol";
import {
    IERC20Errors,
    IERC20,
    ERC20BaseStorage
} from "daosys/tokens/erc20/types/ERC20BaseStorage.sol";


contract ERC20Base is ERC20BaseStorage, IERC20 {

    // string _name;
    // string _symbol;
    // uint8 _decimals;

    // uint256 _totalSupply;

    // mapping(address account => uint256 balance) _balanceOf;
    // mapping(address account => mapping(address spender => uint256 limit)) _allowance;

    function _initREC20(
        string memory name_,
        string memory symbol_,
        uint8 precision_,
        uint256 totalSupply_,
        address recipient
    ) internal virtual {
        // _name = name_;
        // _symbol = symbol_;
        // _decimals = decimals_;
        _initERC20Metadata(
            name_,
            symbol_,
            precision_
        );
        _mint(
            recipient,
            totalSupply_
        );
    }

    function _mint(
        address to,
        uint256 amount
    ) internal virtual {
        _erc20().totalSupply += amount;
        _erc20().balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(
        address from,
        uint256 amount
    ) internal virtual {
        _erc20().totalSupply -= amount;
        _erc20().balanceOf[from] -= amount;
        emit Transfer(from, address(0), amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 bal = _erc20().balanceOf[from];
        if(bal < amount) {
            revert ERC20InsufficientBalance(
                from,
                bal,
                amount
            );
        }
        _erc20().balanceOf[from] = bal - amount;
        _erc20().balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    /* ---------------------------------------------------------------------- */
    /*                             EXTERNAL LOGIC                             */
    /* ---------------------------------------------------------------------- */

    /* ------------------------------- IERC20 ------------------------------- */

    function name()
    public view virtual returns(string memory) {
        return _erc20().name;
    }

    function symbol()
    public view virtual returns(string memory) {
        return _erc20().symbol;
    }

    function decimals()
    external view virtual returns (uint8 precision) {
        return _erc20().precision;
    }

    function totalSupply()
    public view virtual returns(uint256) {
        return _erc20().totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual returns(uint256) {
        return _erc20().balanceOf[account];
    }

    function allowance(
        address holder,
        address spender
    ) public view virtual returns(uint256) {
        return _erc20().allowance[holder][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual returns(bool) {
        if(msg.sender == address(0)) {
            revert ERC20InvalidApprover(msg.sender);
        }
        if(msg.sender == address(0)) {
            revert ERC20InvalidSpender(msg.sender);
        }
        _erc20().allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual returns(bool) {
        _transfer(
            msg.sender,
            recipient,
            amount
        );
        return true;
    }

    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) public virtual returns(bool) {
        if(msg.sender != holder) {
            uint256 allowance_ = _erc20().allowance[holder][msg.sender];
            if(allowance_ < amount) {
                revert ERC20InsufficientAllowance(msg.sender, allowance_, amount);
            }
            _erc20().allowance[holder][msg.sender] = allowance_ - amount;
        }
        _transfer(
            holder,
            recipient,
            amount
        );
        return true;
    }

}