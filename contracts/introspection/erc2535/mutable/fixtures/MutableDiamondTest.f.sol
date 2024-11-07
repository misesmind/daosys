// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/test/vm/VMAware.sol";

import "daosys/introspection/erc2535/mutable/fixtures/MutableDiamondDeployment.f.sol";

import "daosys/introspection/erc2535/behaviors/IDiamondLoupe.b.sol";
import "daosys/dcdi/context/fixtures/ContextTest.f.sol";

contract MutableDiamondTestFixtue
is
VMAware,
// ContextDeploymentFixture,
ContextTestFixture,
MutableDiamondDeploymentFixture,
IDiamondLoupeBehavior
{

    /* ---------------------------------------------------------------------- */
    /*                             Control Values                             */
    /* ---------------------------------------------------------------------- */

    /* ---------------------------------------------------------------------- */
    /*                        MutableDiamondLoupeFacet                        */
    /* ---------------------------------------------------------------------- */

    // function loupeFacet_IERC165_supportedInterfaces()
    // public view virtual returns(bytes4[] memory interfaces) {
    //     interfaces = new bytes4[](3);
    //     interfaces[0] = type(IDCDI).interfaceId;
    //     interfaces[1] = type(IERC165).interfaceId;
    //     interfaces[2] = type(IFacet).interfaceId;
    // }

    // function loupeFacet_IFacet_facetInterfaces()
    // public view virtual
    // // override
    // returns(bytes4[] memory interfaces) {
    //     interfaces = new bytes4[](2);
    //     interfaces[0] = type(IERC165).interfaceId;
    //     interfaces[1] = type(IDiamondLoupe).interfaceId;
    // }

    // function loupeFacet_IFacet_facetFuncs()
    // public pure virtual
    // // override 
    // returns(bytes4[] memory funcs) {
    //     funcs = new bytes4[](5);
    //     funcs[0] = IERC165.supportsInterface.selector;
    //     funcs[1] = IDiamondLoupe.facets.selector;
    //     funcs[2] = IDiamondLoupe.facetFunctionSelectors.selector;
    //     funcs[3] = IDiamondLoupe.facetAddresses.selector;
    //     funcs[4] = IDiamondLoupe.facetAddress.selector;
    // }

}