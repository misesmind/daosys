// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

// import "forge-std/Base.sol";
import "daosys/test/vm/VMAware.sol";
import "forge-std/StdAssertions.sol";

import "daosys/collections/sets/Bytes4SetRepo.sol";

import "daosys/dcdi/context/erc2535/interfaces/IFacet.sol";

contract IFacetBehavior
is
VMAware,
StdAssertions
{

    using Bytes4SetRepo for Bytes4Set;

    /* ---------------------------------------------------------------------- */
    /*                                 IFacet                                 */
    /* ---------------------------------------------------------------------- */

    /* ---------------------------- Expectations ---------------------------- */

    mapping(address subject => Bytes4Set interfaces) control_IFacet_facetinterfaces;
    mapping(address subject => Bytes4Set interfaces) expected_IFacet_facetinterfaces;
    mapping(address subject => Bytes4Set funcs) control_IFacet_facetFuncs;
    mapping(address subject => Bytes4Set funcs) expected_IFacet_facetFuncs;

    /* ---------------------------- Declarations ---------------------------- */

    function declareExpectations_IFacet(
        IFacet subject,
        bytes4[] memory interfaces,
        bytes4[] memory funcs
    ) public {
        expected_IFacet_facetinterfaces
            [address(subject)]
            ._add(interfaces);
        expected_IFacet_facetFuncs
            [address(subject)]
            ._add(funcs);
    }

    /* ----------------------------- Validations ---------------------------- */

    function validate_IFacet_facetInterfaces(IFacet subject)
    public dirtiesState() {
        bytes4[] memory facetInts_ = subject.facetInterfaces();
        for(uint256 cursor = 0; cursor < facetInts_.length; cursor++) {
            assertTrue(
                expected_IFacet_facetinterfaces[address(subject)]._contains(facetInts_[cursor]),
                "Unexpected facet interface declaration."
            );
        }
        control_IFacet_facetinterfaces[address(subject)]._add(facetInts_);
        uint256 expectedLen = expected_IFacet_facetinterfaces[address(subject)]._length();
        assertEq(
            expectedLen,
            facetInts_.length,
            "Declared facet initerface quantity mismatch."
        );
        assertEq(
            facetInts_.length,
            control_IFacet_facetinterfaces[address(subject)]._length(),
            "Duplicate interfaces declared."
        );
        for(uint256 cursor = 0; cursor < expectedLen; cursor++) {
            assertTrue(
                control_IFacet_facetinterfaces[address(subject)]
                    ._contains(
                        expected_IFacet_facetinterfaces[address(subject)]._index(cursor)
                    ),
                "Expected interface NOT declared."
            );
        }
    }

    function validate_IFacet_facetFuncs(IFacet subject)
    public dirtiesState() {
        // uint256 snapShot = vm.snapshotState();
        bytes4[] memory facetFuncs_ = subject.facetFuncs();
        for(uint256 cursor = 0; cursor < facetFuncs_.length; cursor++) {
            assertTrue(
                expected_IFacet_facetFuncs[address(subject)]._contains(facetFuncs_[cursor])
            );
        }
        control_IFacet_facetFuncs[address(subject)]._add(facetFuncs_);
        uint256 expectedLen = expected_IFacet_facetFuncs[address(subject)]._length();
        assertEq(
            expectedLen,
            facetFuncs_.length,
            "Declared facet initerface quantity mismatch."
        );
        assertEq(
            facetFuncs_.length,
            expected_IFacet_facetFuncs[address(subject)]._length(),
            "Duplicate interfaces declared."
        );
        for(uint256 cursor = 0; cursor < expectedLen; cursor++) {
            assertTrue(
                control_IFacet_facetFuncs[address(subject)]
                    ._contains(
                        expected_IFacet_facetFuncs[address(subject)]._index(cursor)
                    ),
                "Expected interface NOT declared."
            );
        }
        // vm.revertToState(snapShot);
    }

    function validate_IFacet(IFacet subject)
    public {
        validate_IFacet_facetInterfaces(subject);
        validate_IFacet_facetFuncs(subject);
    }

}