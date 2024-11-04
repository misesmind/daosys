// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/test/BetterTest.sol";
import "daosys/collections/sets/AddressSetRepo.sol";
import "daosys/collections/sets/Bytes4SetRepo.sol";

/* --------------------------------- DAOSYS --------------------------------- */

import "daosys/introspection/erc165/interfaces/IERC165.sol";
import "daosys/introspection/erc2535/interfaces/IDiamond.sol";
import "daosys/introspection/erc2535/interfaces/IDiamondCut.sol";
import "daosys/introspection/erc2535/interfaces/IDiamondLoupe.sol";
// import "daosys/access/ownable/types/OwnableFacet.sol";
import "daosys/proxy/resolver/ResolverProxy.sol";
// import "daosys/introspection/erc2535/mutable/types/MutableDiamondCutPackage.sol";
// import "daosys/context/types/PrivateContext.sol";

/* --------------------------------- Pachira -------------------------------- */

import "daosys/context/fixtures/ContextDeployment.f.sol";
import "daosys/dcdi/aware/behaviors/IDCDI.b.sol";
import "daosys/introspection/erc165/behaviors/IERC165.b.sol";
import "daosys/context/erc2535/behaviors/IFacet.b.sol";
import "daosys/introspection/erc2535/mutable/fixtures/MutableDiamond.f.sol";

contract MutableDiamondLoupeFacetTest
is
BetterTest,
ContextDeploymentFixture,
MutableDiamondFixture,
IDCDIBehavior,
IERC165Behavior,
IFacetBehavior
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

    // function context()
    // public virtual override returns(Context context_) {
    //     if(address(_context) != address(0)) {
    //         return _context;
    //     }
    //     _context = new Context();
    // }

    function loupeFacet()
    public virtual returns(MutableDiamondLoupeFacet loupeFacet_) {
        return loupeFacet(context());
    }

    /* ---------------------------------------------------------------------- */
    /*                             Control Values                             */
    /* ---------------------------------------------------------------------- */

    bytes32 constant RESOLVER_PROXY_INIT_CODE_HASH = keccak256(type(ResolverProxy).creationCode);

    /* ---------------------------------------------------------------------- */
    /*                        MutableDiamondLoupeFacet                        */
    /* ---------------------------------------------------------------------- */

    function loupeFacet_IERC165_supportedInterfaces()
    public view virtual returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](3);
        interfaces[0] = type(IDCDI).interfaceId;
        interfaces[1] = type(IERC165).interfaceId;
        interfaces[2] = type(IFacet).interfaceId;
    }

    function loupeFacet_IFacet_facetInterfaces()
    public view virtual
    // override
    returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](2);
        interfaces[0] = type(IERC165).interfaceId;
        interfaces[1] = type(IDiamondLoupe).interfaceId;
    }

    function loupeFacet_IFacet_facetFuncs()
    public pure virtual
    // override 
    returns(bytes4[] memory funcs) {
        funcs = new bytes4[](5);
        funcs[0] = IERC165.supportsInterface.selector;
        funcs[1] = IDiamondLoupe.facets.selector;
        funcs[2] = IDiamondLoupe.facetFunctionSelectors.selector;
        funcs[3] = IDiamondLoupe.facetAddresses.selector;
        funcs[4] = IDiamondLoupe.facetAddress.selector;
    }

    /* ---------------------------------------------------------------------- */
    /*                             Initialization                             */
    /* ---------------------------------------------------------------------- */

    function setUp()
    public {
        // vm.createSelectFork("mainnet_infura", 19862653);
        // _context = new Context();

        /* ------------------------------------------------------------------ */
        /*                      MutableDiamondLoupeFacet                      */
        /* ------------------------------------------------------------------ */
        vm.label(address(loupeFacet()), "MutableDiamondLoupeFacet");
        /* ------------------------------ IDCDI ----------------------------- */
        declareExpectations_IDCDI(
            IDCDI(address(loupeFacet())),
            address(context()),
            keccak256(type(MutableDiamondLoupeFacet).creationCode),
            keccak256("")
        );
        /* ----------------------------- IERC165 ---------------------------- */
        declareExpectations_IERRC165(
            IERC165(address(loupeFacet())),
            loupeFacet_IERC165_supportedInterfaces()
        );
        /* ----------------------------- IFacet ----------------------------- */
        declareExpectations_IFacet(
            IFacet(address(loupeFacet())),
            loupeFacet_IFacet_facetInterfaces(),
            loupeFacet_IFacet_facetFuncs()
        );

    }

    /* ---------------------------------------------------------------------- */
    /*                                  Tests                                 */
    /* ---------------------------------------------------------------------- */

    /* ---------------------------------------------------------------------- */
    /*                        MutableDiamondLoupeFacet                        */
    /* ---------------------------------------------------------------------- */

    function test_MutableDiamondLoupeFacet()
    public {
        /* ------------------------------ IDCDI ----------------------------- */
        validate__IDCDI(loupeFacet());
        /* ----------------------------- IERC165 ---------------------------- */
        validate_IERC165(loupeFacet());
        /* ----------------------------- IFacet ----------------------------- */
        validate_IFacet(loupeFacet());
    }

}