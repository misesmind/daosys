// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/test/BetterTest.sol";
import "daosys/collections/sets/AddressSetRepo.sol";
import "daosys/collections/sets/Bytes4SetRepo.sol";

/* --------------------------------- DAOSYS --------------------------------- */

import "daosys/introspection/erc165/interfaces/IERC165.sol";
// import "daosys/introspection/erc2535/interfaces/IDiamond.sol";
// import "daosys/introspection/erc2535/interfaces/IDiamondCut.sol";
// import "daosys/introspection/erc2535/interfaces/IDiamondLoupe.sol";
// import "daosys/proxy/resolver/ResolverProxy.sol";
import "daosys/dcdi/aware/behaviors/IDCDI.b.sol";
import "daosys/introspection/erc165/behaviors/IERC165.b.sol";
import "daosys/dcdi/context/fixtures/ContextTest.f.sol";

contract ContextTest
is
// IDCDIBehavior,
IERC165Behavior,
BetterTest,
ContextTestFixture
{
    using AddressSetRepo for AddressSet;
    using Bytes4SetRepo for Bytes4Set;

    /* ---------------------------------------------------------------------- */
    /*                              Common Utils                              */
    /* ---------------------------------------------------------------------- */

    /* ---------------------------------------------------------------------- */
    /*                            Common Variables                            */
    /* ---------------------------------------------------------------------- */

    /* ---------------------------------------------------------------------- */
    /*                             Test Instances                             */
    /* ---------------------------------------------------------------------- */

    /* ---------------------------------------------------------------------- */
    /*                             Control Values                             */
    /* ---------------------------------------------------------------------- */

    /* ---------------------------------------------------------------------- */
    /*                                 Context                                */
    /* ---------------------------------------------------------------------- */

    function context_IERC165_supportedInterfaces()
    public view virtual returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](3);
        interfaces[0] = type(IERC165).interfaceId;
        interfaces[1] = type(IDCDI).interfaceId;
        interfaces[2] = type(IContext).interfaceId;
    }
    
    /* ---------------------------------------------------------------------- */
    /*                             Initialization                             */
    /* ---------------------------------------------------------------------- */

    function setUp()
    public virtual override
    fork("mainnet_infura", 19862653)
    {
        // vm.createSelectFork("mainnet_infura", 19862653);
        super.setUp();

        /* ------------------------------------------------------------------ */
        /*                               Context                              */
        /* ------------------------------------------------------------------ */
        vm.label(address(context()), "Context");
        /* ------------------------------ IDCDI ----------------------------- */
        declareExpectations_IDCDI(
            IDCDI(address(context())),
            address(this),
            bytes32(0),
            keccak256(""),
            bytes32(0)
        );
        /* ----------------------------- IERC165 ---------------------------- */
        declareExpectations_IERRC165(
            IERC165(address(context())),
            context_IERC165_supportedInterfaces()
        );

    }

    /* ---------------------------------------------------------------------- */
    /*                                  Tests                                 */
    /* ---------------------------------------------------------------------- */

    /* ---------------------------------------------------------------------- */
    /*                                 Context                                */
    /* ---------------------------------------------------------------------- */


    function test_Context()
    public {
        /* ------------------------------ IDCDI ----------------------------- */
        validate__IDCDI(context());
        /* ----------------------------- IERC165 ---------------------------- */
        validate_IERC165(IERC165(address(context())));
    }

}