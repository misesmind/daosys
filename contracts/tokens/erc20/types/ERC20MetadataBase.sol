// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IERC20Errors, IERC20, ERC20BaseStorage} from "./ERC20BaseStorage.sol";

abstract contract ERC20MetadataBase
is
// ERC165Stub,
ERC20BaseStorage
// IERC20
{

    /* ---------------------------------------------------------------------- */
    /*                              Declarations                              */
    /* ---------------------------------------------------------------------- */

    /* ------------------------------- IERC165 ------------------------------ */

    // function _supportedInterfaces()
    // internal pure virtual override returns(bytes4[] memory supportedInterfaces_) {
    //     supportedInterfaces_ = new bytes4[](2);
    //     supportedInterfaces_[0] = type(IERC165).interfaceId;
    //     supportedInterfaces_[1] = type(IERC20).interfaceId;
    //     // supportedInterfaces_[2] = type(IMoneyMarket).interfaceId;
    // }

    // function _functionSelectors()
    // internal pure virtual override returns(bytes4[] memory funcs_) {
    //     funcs_ = new bytes4[](10);
    //     funcs_[0] = IERC165.supportsInterface.selector;
    //     funcs_[1] = IERC20.name.selector;
    //     funcs_[2] = IERC20.symbol.selector;
    //     funcs_[3] = IERC20.decimals.selector;
    //     funcs_[4] = IERC20.totalSupply.selector;
    //     funcs_[5] = IERC20.balanceOf.selector;
    //     funcs_[6] = IERC20.allowance.selector;
    //     funcs_[7] = IERC20.approve.selector;
    //     funcs_[8] = IERC20.transfer.selector;
    //     funcs_[9] = IERC20.transferFrom.selector;
    // }

    /* ---------------------------------------------------------------------- */
    /*                             External Logic                             */
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

}