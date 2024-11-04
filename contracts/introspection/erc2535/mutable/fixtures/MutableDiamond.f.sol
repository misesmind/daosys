// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/context/types/Context.sol";
import "daosys/introspection/erc2535/mutable/types/MutableDiamondLoupeFacet.sol";
import "daosys/context/initializers/erc2535/types/MutableERC2535ContextInitializer.sol";
import "daosys/introspection/erc2535/mutable/types/MutableDiamondCutPackage.sol";

contract MutableDiamondFixture {

    MutableDiamondLoupeFacet internal _loupeFacet;

    function loupeFacet(IContext context_)
    public virtual returns(MutableDiamondLoupeFacet loupeFacet_) {
        if(address(_loupeFacet) != address(0)) {
            return _loupeFacet;
        }
        _loupeFacet = MutableDiamondLoupeFacet(
            context_
                .deployContract(
                    type(MutableDiamondLoupeFacet).creationCode,
                    ""
                )
        );
        return _loupeFacet;
    }

    MutableERC2535ContextInitializer internal _diamondIniter;

    function diamondIniter(IContext context_)
    public virtual returns(MutableERC2535ContextInitializer diamondIniter_) {
        if(address(_diamondIniter) != address(0)) {
            return _diamondIniter;
        }
        _diamondIniter = MutableERC2535ContextInitializer(
            context_
                .deployContract(
                    type(MutableERC2535ContextInitializer).creationCode,
                    abi.encode(loupeFacet(context_))
                )
        );
        return _diamondIniter;
    }

    MutableDiamondCutPackage internal _diamondCutPkg;

    function diamondCutPkg(
        IContext context_,
        address ownableFacet
    )
    public returns(MutableDiamondCutPackage diamondCutPkg_) {
        if(address(_diamondCutPkg) == address(0)) {
            _diamondCutPkg = MutableDiamondCutPackage(
                context_
                    .deployContract(
                        type(MutableDiamondCutPackage).creationCode,
                        // ""
                        abi.encode(ownableFacet)
                    )
            );
        }
        return _diamondCutPkg;
    }

}