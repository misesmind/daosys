// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/dcdi/interfaces/IDCDI.sol";
import "daosys/introspection/erc165/interfaces/IERC165.sol";
import "daosys/context/erc2535/types/FacetDiamondPackage.sol";
import "daosys/tokens/erc20/types/ERC20OpertableMintableTarget.sol";

contract ERC20OpertableMintableTargetPackage
is
ERC20OpertableMintableTarget,
FacetDiamondPackage
{

    // function supportedInterfaces()
    // public view virtual override returns(bytes4[] memory interfaces) {
    //     interfaces = new bytes4[](5);
    //     // interfaces[0] = type(IERC165).interfaceId;
    //     interfaces[0] = type(IDCDI).interfaceId;
    //     interfaces[1] = type(IERC20).interfaceId;
    //     interfaces[2] = type(IOwnable).interfaceId;
    //     interfaces[3] = type(IOperatable).interfaceId;
    //     interfaces[4] = type(IERC20Mintable).interfaceId;
    // }

    function facetInterfaces()
    public view virtual 
    override(
        FacetDiamondPackage
    )
    returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](4);
        interfaces[0] = type(IERC20).interfaceId;
        interfaces[1] = type(IOwnable).interfaceId;
        interfaces[2] = type(IOperatable).interfaceId;
        interfaces[3] = type(IERC20Mintable).interfaceId;
    }

    function facetFuncs()
    public pure virtual override returns(bytes4[] memory funcs) {
        funcs = new bytes4[](18);
        funcs[0] = IERC20.name.selector;
        funcs[1] = IERC20.symbol.selector;
        funcs[2] = IERC20.decimals.selector;
        funcs[3] = IERC20.totalSupply.selector;
        funcs[4] = IERC20.balanceOf.selector;
        funcs[5] = IERC20.allowance.selector;
        funcs[6] = IERC20.approve.selector;
        funcs[7] = IERC20.transfer.selector;
        funcs[8] = IERC20.transferFrom.selector;
        funcs[9] = IOwnable.owner.selector;
        funcs[10] = IOwnable.proposedOwner.selector;
        funcs[11] = IOwnable.transferOwnership.selector;
        funcs[12] = IOwnable.acceptOwnership.selector;
        funcs[13] = IOwnable.renounceOwnership.selector;
        funcs[14] = IOperatable.isOperator.selector;
        funcs[15] = IOperatable.setOperator.selector;
        funcs[16] = IERC20Mintable.mint.selector;
        funcs[17] = IERC20Mintable.burn.selector;
        // funcs[16] = bytes4(keccak256(bytes("mint(uint256,address)")));
        // funcs[17] = bytes4(keccak256(bytes("mint(address,uint256)")));
        // funcs[18] = bytes4(keccak256(bytes("burn(uint256,address)")));
        // funcs[19] = bytes4(keccak256(bytes("burn(address,uint256)")));
    }

    // function facetCuts()
    // public view virtual override returns(IDiamond.FacetCut[] memory facetCuts_) {
    //     facetCuts_ = new IDiamond.FacetCut[](1);
    //     facetCuts_[0] = IDiamond.FacetCut({
    //         // address facetAddress;
    //         facetAddress: self(),
    //         // FacetCutAction action;
    //         action: IDiamond.FacetCutAction.Add,
    //         // bytes4[] functionSelectors;
    //         functionSelectors: facetFuncs()
    //     });
    // }

    function initAccount(
        bytes memory initArgs
    ) public virtual override {
        (
            string memory tokenName,
            string memory tokenSymbol,
            uint8 tokenDecimals,
            uint256 newTokenSupply,
            address owner_
        ) = abi.decode(
            initArgs,
            (
                string,
                string,
                uint8,
                uint256,
                address
            )
        );
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