// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./security/ReentrancyGuard.sol";
import {Math} from "./math/Math.sol";
import "./math/SafeMath.sol";
import {ERC20} from "./erc20/ERC20.sol";
// import {IERC20} from "contracts/tokens/erc20/interfaces/IERC20.sol";
import "./libraries/UniERC20.sol";
import "./libraries/Sqrt.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import {VirtualBalance} from "./libraries/VirtualBalance.sol";





contract Mooniswap is IERC20, ERC20, ReentrancyGuard, Ownable {
    using Sqrt for uint256;
    using SafeMath for uint256;
    using UniERC20 for IERC20;
    using VirtualBalance for VirtualBalance.Data;

    struct Balances {
        uint256 src;
        uint256 dst;
    }

    struct SwapVolumes {
        uint128 confirmed;
        uint128 result;
    }

    event Deposited(
        address indexed account,
        uint256 amount
    );

    event Withdrawn(
        address indexed account,
        uint256 amount
    );

    event Swapped(
        address indexed account,
        address indexed src,
        address indexed dst,
        uint256 amount,
        uint256 result,
        uint256 srcBalance,
        uint256 dstBalance,
        uint256 totalSupply,
        address referral
    );

    uint256 public constant REFERRAL_SHARE = 20; // 1/share = 5% of LPs revenue
    uint256 public constant BASE_SUPPLY = 1000;  // Total supply on first deposit
    uint256 public constant FEE_DENOMINATOR = 1e18;

    IFactory public factory;
    IERC20[] public tokens;
    mapping(IERC20 => bool) public isToken;
    mapping(IERC20 => SwapVolumes) public volumes;
    mapping(IERC20 => VirtualBalance.Data) public virtualBalancesForAddition;
    mapping(IERC20 => VirtualBalance.Data) public virtualBalancesForRemoval;

    constructor(
        IERC20[] memory assets,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        require(bytes(name_).length > 0, "Mooniswap: name is empty");
        require(bytes(symbol_).length > 0, "Mooniswap: symbol is empty");
        require(assets.length == 2, "Mooniswap: only 2 tokens allowed");

        factory = IFactory(msg.sender);
        tokens = assets;
        for (uint i = 0; i < assets.length; i++) {
            require(!isToken[assets[i]], "Mooniswap: duplicate tokens");
            isToken[assets[i]] = true;
        }
    }

    function fee() public view returns(uint256) {
        return factory.fee();
    }

    function getTokens() external view returns(IERC20[] memory) {
        return tokens;
    }

    function decayPeriod() external pure returns(uint256) {
        return VirtualBalance.DECAY_PERIOD;
    }

    function getBalanceForAddition(IERC20 token) public view returns(uint256) {
        uint256 balance = token.uniBalanceOf(address(this));
        return Math.max(virtualBalancesForAddition[token].current(balance), balance);
    }

    function getBalanceForRemoval(IERC20 token) public view returns(uint256) {
        uint256 balance = token.uniBalanceOf(address(this));
        return Math.min(virtualBalancesForRemoval[token].current(balance), balance);
    }

    function getReturn(IERC20 src, IERC20 dst, uint256 amount) external view returns(uint256) {
        return _getReturn(src, dst, amount, getBalanceForAddition(src), getBalanceForRemoval(dst));
    }

    function mint(uint256 amount) external {
        _mint(address(this), amount);
    }    

    /// @notice Same as `depositFor` but for `msg.sender`
    function deposit(uint256[] memory maxAmounts, uint256[] memory minAmounts) external payable returns(uint256 fairSupply) {
        return depositFor(maxAmounts, minAmounts, payable(msg.sender));
    }

    function depositFor(uint256[] memory amounts, uint256[] memory minAmounts, address to) public payable returns(uint256 fairSupply) {
        IERC20[] memory _tokens = tokens;
        require(amounts.length == _tokens.length, "Mooniswap: wrong amounts length");
        require(msg.value == (_tokens[0].isETH() ? amounts[0] : (_tokens[1].isETH() ? amounts[1] : 0)), "Mooniswap: wrong value usage");

        uint256[] memory realBalances = new uint256[](amounts.length);
        for (uint i = 0; i < realBalances.length; i++) {
            realBalances[i] = _tokens[i].uniBalanceOf(address(this)).sub(_tokens[i].isETH() ? msg.value : 0);
        }

        uint256 totalSupply_ = totalSupply();
        if (totalSupply_ == 0) {
            fairSupply = BASE_SUPPLY.mul(99);
            _mint(address(this), BASE_SUPPLY); // Donate up to 1%

            // Use the greatest token amount but not less than 99k for the initial supply
            for (uint i = 0; i < amounts.length; i++) {
                fairSupply = Math.max(fairSupply, amounts[i]);
            }
        }
        else {
            // Pre-compute fair supply
            fairSupply = type(uint256).max;
            for (uint i = 0; i < amounts.length; i++) {
                fairSupply = Math.min(fairSupply, totalSupply_.mul(amounts[i]).div(realBalances[i]));
            }
        }

        uint256 fairSupplyCached = fairSupply;
        for (uint i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "Mooniswap: amount is zero");
            uint256 amount = (totalSupply_ == 0) ? amounts[i] :
                realBalances[i].mul(fairSupplyCached).add(totalSupply_ - 1).div(totalSupply);
            require(amount >= minAmounts[i], "Mooniswap: minAmount not reached");

            _tokens[i].uniTransferFromSenderToThis(amount);
            if (totalSupply_ > 0) {
                uint256 confirmed = _tokens[i].uniBalanceOf(address(this)).sub(realBalances[i]);
                fairSupply = Math.min(fairSupply, totalSupply_.mul(confirmed).div(realBalances[i]));
            }
        }

        if (totalSupply_ > 0) {
            for (uint i = 0; i < amounts.length; i++) {
                virtualBalancesForRemoval[_tokens[i]].scale(realBalances[i], totalSupply.add(fairSupply), totalSupply);
                virtualBalancesForAddition[_tokens[i]].scale(realBalances[i], totalSupply.add(fairSupply), totalSupply);
            }
        }

        require(fairSupply > 0, "Mooniswap: result is not enough");
        // _mint(msg.sender, fairSupply);
        _mint(to, fairSupply);

        // emit Deposited(msg.sender, fairSupply);
        emit Deposited(to, fairSupply);
    }

    /// @notice Same as `withdrawFor` but for `msg.sender`
    function withdraw(uint256 amount, uint256[] memory minReturns) external {
        withdrawFor(amount, minReturns, payable(msg.sender));
    }

    function withdrawFor(uint256 amount, uint256[] memory minReturns, address payable to) public {
        uint256 totalSupply_ = totalSupply();
        _burn(msg.sender, amount);

        for (uint i = 0; i < tokens.length; i++) {
            IERC20 token = tokens[i];

            uint256 preBalance = token.uniBalanceOf(address(this));
            uint256 value = preBalance.mul(amount).div(totalSupply_);
            // token.uniTransfer(payable(address(msg.sender)), value);
            token.uniTransfer(payable(address(to)), value);
            require(i >= minReturns.length || value >= minReturns[i], "Mooniswap: result is not enough");

            virtualBalancesForAddition[token].scale(preBalance, totalSupply_.sub(amount), totalSupply_);
            virtualBalancesForRemoval[token].scale(preBalance, totalSupply_.sub(amount), totalSupply_);
        }

        // emit Withdrawn(msg.sender, amount);
        emit Withdrawn(to, amount);
    }

    /// @notice Same as `swapFor` but for `msg.sender`
    function swap(IERC20 src, IERC20 dst, uint256 amount, uint256 minReturn, address referral) external payable returns(uint256 result) {
        return swapFor(src, dst, amount, minReturn, referral, payable(msg.sender));
    }

    function swapFor(
      IERC20 src,
      IERC20 dst,
      uint256 amount,
      uint256 minReturn,
      address referral,
      address payable receiver
    ) public payable returns(uint256 result) {
        require(msg.value == (src.isETH() ? amount : 0), "Mooniswap: wrong value usage");

        Balances memory balances = Balances({
            src: src.uniBalanceOf(address(this)).sub(src.isETH() ? msg.value : 0),
            dst: dst.uniBalanceOf(address(this))
        });

        // catch possible airdrops and external balance changes for deflationary tokens
        uint256 srcAdditionBalance = Math.max(virtualBalancesForAddition[src].current(balances.src), balances.src);
        uint256 dstRemovalBalance = Math.min(virtualBalancesForRemoval[dst].current(balances.dst), balances.dst);

        src.uniTransferFromSenderToThis(amount);
        uint256 confirmed = src.uniBalanceOf(address(this)).sub(balances.src);
        result = _getReturn(src, dst, confirmed, srcAdditionBalance, dstRemovalBalance);
        require(result > 0 && result >= minReturn, "Mooniswap: return is not enough");
        // dst.uniTransfer(payable(address(msg.sender)), result);
        dst.uniTransfer(payable(address(receiver)), result);

        // Update virtual balances to the same direction only at imbalanced state
        if (srcAdditionBalance != balances.src) {
            virtualBalancesForAddition[src].set(srcAdditionBalance.add(confirmed));
        }
        if (dstRemovalBalance != balances.dst) {
            virtualBalancesForRemoval[dst].set(dstRemovalBalance.sub(result));
        }

        // Update virtual balances to the opposite direction
        virtualBalancesForRemoval[src].update(balances.src);
        virtualBalancesForAddition[dst].update(balances.dst);

        if (referral != address(0)) {
            uint256 invariantRatio = uint256(1e36);
            invariantRatio = invariantRatio.mul(balances.src.add(confirmed)).div(balances.src);
            invariantRatio = invariantRatio.mul(balances.dst.sub(result)).div(balances.dst);
            if (invariantRatio > 1e36) {
                // calculate share only if invariant increased
                uint256 referralShare = invariantRatio.sqrt().sub(1e18).mul(totalSupply()).div(1e18).div(REFERRAL_SHARE);
                if (referralShare > 0) {
                    _mint(referral, referralShare);
                }
            }
        }

        // emit Swapped(msg.sender, address(src), address(dst), confirmed, result, balances.src, balances.dst, totalSupply(), referral);
        emit Swapped(receiver, address(src), address(dst), confirmed, result, balances.src, balances.dst, totalSupply(), referral);

        // Overflow of uint128 is desired
        volumes[src].confirmed += uint128(confirmed);
        volumes[src].result += uint128(result);
    }

    function rescueFunds(IERC20 token, uint256 amount) external {
        uint256[] memory balances = new uint256[](tokens.length);
        for (uint i = 0; i < balances.length; i++) {
            balances[i] = tokens[i].uniBalanceOf(address(this));
        }

        token.uniTransfer(payable(address(msg.sender)), amount);

        for (uint i = 0; i < balances.length; i++) {
            require(tokens[i].uniBalanceOf(address(this)) >= balances[i], "Mooniswap: access denied");
        }
        require(balanceOf(address(this)) >= BASE_SUPPLY, "Mooniswap: access denied");
    }

    function _getReturn(
        IERC20 src,
        IERC20 dst,
        uint256 amount,
        uint256 srcBalance,
        uint256 dstBalance
    ) internal view returns(uint256 returnAmount) {
        if (isToken[src] && isToken[dst] && src != dst && amount > 0) {
            uint256 taxedAmount = amount.sub(amount.mul(fee()).div(FEE_DENOMINATOR));
            return taxedAmount.mul(dstBalance).div(srcBalance.add(taxedAmount));
        }
    }
}