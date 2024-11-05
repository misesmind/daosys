// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/context/types/Context.sol";
import "daosys/access/ownable/types/OwnableFacet.sol";
import "daosys/context/fixtures/ContextDeployment.f.sol";

contract OwnableFixture
is
ContextDeploymentFixture
{

    OwnableFacet internal _ownableFacet;

    function ownableFacet()
    public returns(OwnableFacet ownableFacet_) {
        return ownableFacet(context());
    }

    function ownableFacet(IContext context_)
    public returns(OwnableFacet ownableFacet_) {
        if(address(_ownableFacet) == address(0)) {
            _ownableFacet = OwnableFacet(
                context_
                    .deployContract(
                        type(OwnableFacet).creationCode,
                        ""
                    )
            );
        }
        return _ownableFacet;
    }

}