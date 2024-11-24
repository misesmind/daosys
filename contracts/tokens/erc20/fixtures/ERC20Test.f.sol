// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/* --------------------------------- DAOSYS --------------------------------- */

import "daosys/primitives/UInt.sol";
import "daosys/dcdi/context/fixtures/Context.f.sol";
import "daosys/introspection/erc2535/mutable/fixtures/MutableDiamondDeployment.f.sol";

import "daosys/tokens/erc20/types/ERC20OpertableMintableTargetPackage.sol";
import "daosys/introspection/erc2535/mutable/fixtures/MutableDiamondTest.f.sol";

contract ERC20TestFixture
is
// ContextDeploymentFixture,
MutableDiamondTestFixtue
{

    using UInt for uint256;

    string constant ERC20_NAME_PREFIX = "Test Token ";
    string constant ERC20_SYMBOL_PREFIX = "TT";
    uint8 constant ERC20_DEFAULT_DECIMALS = 18;

    uint256 tokenCount;

    mapping(uint256 tokenId => IERC20OperatableMintable token) _deployedTokens;

    ERC20OpertableMintableTargetPackage _erc20Pkg;

    function erc20Pkg()
    public virtual returns(ERC20OpertableMintableTargetPackage erc20Pkg_) {
        return erc20Pkg(context());
        // return erc20Pkg(pachiraContext());
    }

    function erc20Pkg(IContext context_)
    public virtual returns(ERC20OpertableMintableTargetPackage erc20Pkg_) {
        if(address(_erc20Pkg) == address(0)) {
            _erc20Pkg = ERC20OpertableMintableTargetPackage(
                // pachiraContext()
                // context()
                context_
                    .deployContract(
                        type(ERC20OpertableMintableTargetPackage).creationCode,
                        ""
                    )
            );
        }
        return _erc20Pkg;
    }

    function erc20Stub()
    public virtual returns(IERC20OperatableMintable token) {
        return erc20Stub(
            address(this)
        );
    }

    function erc20Stub(
        IContext context_,
        IContextInitializer initer
    )
    public virtual returns(IERC20OperatableMintable token) {
        return erc20Stub(
            context_,
            initer,
            address(this)
        );
    }

    function erc20Stub(
        address owner_
    ) public virtual returns(IERC20OperatableMintable token) {
        return erc20Stub(
            context(),
            diamondIniter(),
            "",
            "",
            0,
            0,
            owner_
        );
    }

    function erc20Stub(
        IContext context_,
        IContextInitializer initer,
        address owner_
    ) public virtual returns(IERC20OperatableMintable token) {
        return erc20Stub(
            context_,
            initer,
            "",
            "",
            0,
            0,
            owner_
        );
    }

    function erc20Stub(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 tokenTotalSupply,
        address owner_
    ) public virtual returns(IERC20OperatableMintable token) {
        return erc20Stub(
            context(),
            diamondIniter(),
            tokenName,
            tokenSymbol,
            tokenDecimals,
            tokenTotalSupply,
            owner_
        );
    }

    function erc20Stub(
        IContext context_,
        IContextInitializer initer,
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 tokenTotalSupply,
        address owner_
    ) public virtual returns(IERC20OperatableMintable token) {
        uint256 tokenId = tokenCount;
        tokenCount = tokenCount + 1;

        if(bytes(tokenName).length == 0) {
            tokenName = string.concat(ERC20_NAME_PREFIX, tokenId._toString());
        }

        if(bytes(tokenSymbol).length == 0) {
            tokenSymbol = string.concat(ERC20_SYMBOL_PREFIX, tokenId._toString());
        }

        if(tokenDecimals == 0) {
            tokenDecimals = ERC20_DEFAULT_DECIMALS;
        }

        // IERC20OperatableMintable lastToken = tokenId == 0
        //     ? IERC20OperatableMintable(address(0))
        //     : _deployedTokens[tokenId - 1];

        token = IERC20OperatableMintable(
            // pachiraContext()
            // context()
            context_
                .deployWithIniter(
                    initer,
                    erc20Pkg(
                        context_
                    ),
                    abi.encode(
                        tokenName,
                        tokenSymbol,
                        tokenDecimals,
                        tokenTotalSupply,
                        owner_
                    )
                )
        );
        _deployedTokens[tokenId] = token;
        IOperatable(address(token)).setOperator(address(owner_), true);
    }

}