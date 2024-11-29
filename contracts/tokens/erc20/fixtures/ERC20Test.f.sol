// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
import "forge-std/console.sol";
// import "forge-std/console2.sol";

/* --------------------------------- DAOSYS --------------------------------- */

// import {Address} from "daosys/primitives/Address.sol";
import "daosys/primitives/UInt.sol";
import "daosys/dcdi/context/fixtures/Context.f.sol";
import "daosys/introspection/erc2535/mutable/fixtures/MutableDiamondDeployment.f.sol";

import "daosys/tokens/erc20/types/ERC20OperatableMintableTargetPackage.sol";
import "daosys/introspection/erc2535/mutable/fixtures/MutableDiamondTest.f.sol";

contract ERC20TestFixture
is
// ContextDeploymentFixture,
MutableDiamondTestFixture
{

    using Address for address;
    using UInt for uint256;

    ERC20OperatableMintableTargetPackage _erc20Pkg;

    function erc20Pkg(IContext context_)
    public virtual returns(ERC20OperatableMintableTargetPackage erc20Pkg_) {
        if(address(_erc20Pkg) == address(0)) {
            _erc20Pkg = ERC20OperatableMintableTargetPackage(
                // pachiraContext()
                // context()
                context_
                    .deployContract(
                        type(ERC20OperatableMintableTargetPackage).creationCode,
                        ""
                    )
            );
            vm.label(
                address(_erc20Pkg),
                "ERC20OperatableMintableTargetPackage"
            );
        }
        return _erc20Pkg;
    }

    function erc20Pkg()
    public virtual returns(ERC20OperatableMintableTargetPackage erc20Pkg_) {
        return erc20Pkg(context());
        // return erc20Pkg(pachiraContext());
    }

    string constant ERC20_NAME_PREFIX = "Test Token ";
    string constant ERC20_SYMBOL_PREFIX = "TT";
    uint8 constant ERC20_DEFAULT_DECIMALS = 18;

    uint256 tokenCount;

    mapping(uint256 tokenId => IERC20OperatableMintable token) _deployedTokens;

    function erc20Stub(
        IContext context_,
        IContextInitializer initer,
        uint256 tokenId,
        address owner_,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 tokenTotalSupply,
        uint8 tokenDecimals
    ) public virtual returns(IERC20OperatableMintable token) {
        token = _deployedTokens[tokenId];
        if(address(token) != address(0)) {
            return token;
        }

        if(tokenId == 0) {
            tokenId = tokenCount + 1;
        }
        tokenCount = tokenId;

        token = IERC20OperatableMintable(
            context_
                .deployWithIniter(
                    initer,
                    erc20Pkg(
                        context_
                    ),
                    abi.encode(
                        bytes(tokenName).length != 0?tokenName:string.concat(ERC20_NAME_PREFIX, tokenId._toString()),
                        bytes(tokenSymbol).length != 0?tokenSymbol:string.concat(ERC20_SYMBOL_PREFIX, tokenId._toString()),
                        tokenDecimals != 0?tokenDecimals:ERC20_DEFAULT_DECIMALS,
                        tokenTotalSupply,
                        owner_
                    )
                )
        );
        _deployedTokens[tokenId] = token;
        vm.label(
            address(token),
            token.symbol()
        );
        vm.prank(owner_);
        IOperatable(address(token)).setOperator(address(owner_), true);
    }

    function erc20Stub(
        uint256 tokenId,
        address owner_
    ) public virtual returns(IERC20OperatableMintable token) {
        // return erc20Stub(
        //     context(),
        //     diamondIniter(),
        //     tokenId,
        //     owner_
        // );
        return erc20Stub(
            context(),
            diamondIniter(),
            tokenId,
            owner_,
            "",
            "",
            0,
            0
        );
    }

    function erc20Stub(
        address owner_
    ) public virtual returns(IERC20OperatableMintable token) {
        return erc20Stub(
            // context(),
            // diamondIniter(),
            0,
            owner_
        );
    }

    // function erc20Stub(
    //     uint256 tokenId,
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol,
    //     uint256 tokenTotalSupply,
    //     uint8 tokenDecimals
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context(),
    //         diamondIniter(),
    //         tokenId,
    //         owner_,
    //         tokenName,
    //         tokenSymbol,
    //         tokenTotalSupply,
    //         tokenDecimals
    //     );
    // }

    // function erc20Stub(
    //     IContext context_,
    //     IContextInitializer initer,
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol,
    //     uint256 tokenTotalSupply,
    //     uint8 tokenDecimals
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context_,
    //         initer,
    //         0,
    //         owner_,
    //         tokenName,
    //         tokenSymbol,
    //         tokenTotalSupply,
    //         tokenDecimals
    //     );
    // }

    // function erc20Stub(
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol,
    //     uint256 tokenTotalSupply,
    //     uint8 tokenDecimals
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context(),
    //         diamondIniter(),
    //         owner_,
    //         tokenName,
    //         tokenSymbol,
    //         tokenTotalSupply,
    //         tokenDecimals
    //     );
    // }

    // function erc20Stub(
    //     IContext context_,
    //     IContextInitializer initer,
    //     uint256 tokenId,
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol,
    //     uint256 tokenTotalSupply
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context_,
    //         initer,
    //         tokenId,
    //         owner_,
    //         tokenName,
    //         tokenSymbol,
    //         tokenTotalSupply,
    //         0
    //     );
    // }

    // function erc20Stub(
    //     uint256 tokenId,
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol,
    //     uint256 tokenTotalSupply
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context(),
    //         diamondIniter(),
    //         tokenId,
    //         owner_,
    //         tokenName,
    //         tokenSymbol,
    //         tokenTotalSupply
    //     );
    // }

    // function erc20Stub(
    //     IContext context_,
    //     IContextInitializer initer,
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol,
    //     uint256 tokenTotalSupply
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context_,
    //         initer,
    //         0,
    //         owner_,
    //         tokenName,
    //         tokenSymbol,
    //         tokenTotalSupply
    //     );
    // }

    // function erc20Stub(
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol,
    //     uint256 tokenTotalSupply
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context(),
    //         diamondIniter(),
    //         owner_,
    //         tokenName,
    //         tokenSymbol,
    //         tokenTotalSupply
    //     );
    // }

    // function erc20Stub(
    //     IContext context_,
    //     IContextInitializer initer,
    //     uint256 tokenId,
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context_,
    //         initer,
    //         tokenId,
    //         owner_,
    //         tokenName,
    //         tokenSymbol
    //     );
    // }

    // function erc20Stub(
    //     uint256 tokenId,
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context(),
    //         diamondIniter(),
    //         tokenId,
    //         owner_,
    //         tokenName,
    //         tokenSymbol
    //     );
    // }

    // function erc20Stub(
    //     IContext context_,
    //     IContextInitializer initer,
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context_,
    //         initer,
    //         0,
    //         owner_,
    //         tokenName,
    //         tokenSymbol,
    //         0,
    //         0
    //     );
    // }

    // function erc20Stub(
    //     address owner_,
    //     string memory tokenName,
    //     string memory tokenSymbol
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context(),
    //         diamondIniter(),
    //         owner_,
    //         tokenName,
    //         tokenSymbol
    //     );
    // }

    // function erc20Stub(
    //     IContext context_,
    //     IContextInitializer initer,
    //     uint256 tokenId,
    //     address owner_
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context_,
    //         initer,
    //         tokenId,
    //         owner_,
    //         "",
    //         ""
    //     );
    // }

    // function erc20Stub(
    //     IContext context_,
    //     IContextInitializer initer,
    //     address owner_
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context_,
    //         initer,
    //         0,
    //         owner_
    //     );
    // }

    // function erc20Stub()
    // public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         address(this)
    //     );
    // }

    // function erc20Stub(
    //     string memory tokenName,
    //     string memory tokenSymbol,
    //     uint8 tokenDecimals,
    //     uint256 tokenTotalSupply,
    //     address owner_
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context(),
    //         diamondIniter(),
    //         tokenName,
    //         tokenSymbol,
    //         tokenDecimals,
    //         tokenTotalSupply,
    //         owner_
    //     );
    // }

    /* ---------------------------------------------------------------------- */
    /*                        REFACTORED CODE IS ABOVE                        */
    /* ---------------------------------------------------------------------- */

    // TODO Deprecate
    // function erc20Stub(
    //     IContext context_,
    //     IContextInitializer initer,
    //     string memory tokenName,
    //     string memory tokenSymbol,
    //     uint8 tokenDecimals,
    //     uint256 tokenTotalSupply,
    //     address owner_
    // ) public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context_,
    //         initer,
    //         0,
    //         owner_,
    //         tokenName,
    //         tokenSymbol,
    //         tokenTotalSupply,
    //         tokenDecimals
    //     );
    // }

    // function erc20Stub(
    //     IContext context_,
    //     IContextInitializer initer
    // )
    // public virtual returns(IERC20OperatableMintable token) {
    //     return erc20Stub(
    //         context_,
    //         initer,
    //         address(this)
    //     );
    // }

}