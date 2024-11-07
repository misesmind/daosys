// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/test/vm/VMAware.sol";
import "forge-std/StdAssertions.sol";
import "daosys/collections/sets/AddressSetRepo.sol";
import "daosys/collections/sets/Bytes4SetRepo.sol";

import "daosys/dcdi/context/erc2535/interfaces/IDiamondPackage.sol";

contract IDiamondPackageBehavior
is
VMAware,
StdAssertions
{
    using AddressSetRepo for AddressSet;
    using Bytes4SetRepo for Bytes4Set;

    /* ---------------------------- Expectations ---------------------------- */

    mapping(address subject => Bytes4Set interfaces) control_IDiamondPackage_facetinterfaces;
    mapping(address subject => Bytes4Set interfaces) expected_IDiamondPackage_facetinterfaces;
    mapping(address subject => AddressSet facets) control_IDiamondPackage_facetAddrressesOf_facetCuts;
    mapping(address subject => AddressSet facets) expected_IDiamondPackage_facetAddrressesOf_facetCuts;
    mapping(address subject => IDiamond.FacetCutAction action) expect_IDiamondPackage_actionOf_FacetCut;
    mapping(address subject => mapping(address facet => Bytes4Set)) control_IDiamondPackage_facetFuncsOf_facetCuts;
    mapping(address subject => mapping(address facet => Bytes4Set)) expected_IDiamondPackage_facetFuncsOf_facetCuts;

    /* ---------------------------- Declarations ---------------------------- */

    function declareExpectations_IDiamondPackage(
        IDiamondPackage subject,
        IDiamond.FacetCut[] memory facetCuts_,
        bytes4[] memory facetInterfaces
    ) public {
        expected_IDiamondPackage_facetinterfaces
            [address(subject)]
            ._add(facetInterfaces);
        for(uint256 cursor = 0; cursor < facetCuts_.length; cursor++) {
            expected_IDiamondPackage_facetAddrressesOf_facetCuts
                [address(subject)]
                ._add(facetCuts_[cursor].facetAddress);
            expect_IDiamondPackage_actionOf_FacetCut
                [address(subject)]
                = facetCuts_[cursor].action;
            expected_IDiamondPackage_facetFuncsOf_facetCuts
                [address(subject)]
                [facetCuts_[cursor].facetAddress]
                ._add(facetCuts_[cursor].functionSelectors);
        }
    }

    function declareExpectations_IDiamondPackage(
        IDiamondPackage subject,
        IDiamondPackage.DiamondConfig memory diamondConfig
    ) public {
        declareExpectations_IDiamondPackage(
            subject,
            diamondConfig.facetCuts_,
            diamondConfig.interfaces
        );
    }

    /* ----------------------------- Validations ---------------------------- */

    function validate_IDiamondPackage_facetInterfaces(
        IDiamondPackage subject, 
        bytes4[] memory facetInts_
    ) public dirtiesState() {
        // uint256 snapShot = vm.snapshotState();
        // bytes4[] memory facetInts_ = IDiamondPackage(address(subject)).facetInterfaces();
        for(uint256 cursor = 0; cursor < facetInts_.length; cursor++) {
            assertTrue(
                expected_IDiamondPackage_facetinterfaces[address(subject)]._contains(facetInts_[cursor]),
                "Unexpected facet interface declaration."
            );
        }
        control_IDiamondPackage_facetinterfaces[address(subject)]._add(facetInts_);
        uint256 expectedLen = expected_IDiamondPackage_facetinterfaces[address(subject)]._length();
        assertEq(
            expectedLen,
            facetInts_.length,
            "Declared facet initerface quantity mismatch."
        );
        assertEq(
            facetInts_.length,
            control_IDiamondPackage_facetinterfaces[address(subject)]._length(),
            "Duplicate interfaces declared."
        );
        for(uint256 cursor = 0; cursor < expectedLen; cursor++) {
            assertTrue(
                control_IDiamondPackage_facetinterfaces[address(subject)]
                    ._contains(
                        expected_IDiamondPackage_facetinterfaces[address(subject)]._index(cursor)
                    ),
                "Expected interface NOT declared."
            );
        }
        // vm.revertToState(snapShot);
    }

    function validate_IDiamondPackage_facetInterfaces(IDiamondPackage subject)
    public {
        // bytes4[] memory facetInts_ = IDiamondPackage(address(subject)).facetInterfaces();
        validate_IDiamondPackage_facetInterfaces(
            subject, 
            IDiamondPackage(address(subject)).facetInterfaces()
        );
    }

    function validate_IDiamondPackage_facetCuts(
        IDiamondPackage subject,
        IDiamond.FacetCut[] memory facetCuts_
    ) public dirtiesState() {
        // uint256 snapShot = vm.snapshotState();
        // IDiamond.FacetCut[] memory facetCuts_ = IDiamondPackage(address(subject)).facetCuts();
        uint256 expectedFacetCutLen_ = expected_IDiamondPackage_facetAddrressesOf_facetCuts
            [address(subject)]._length();
        assertEq(
            expectedFacetCutLen_,
            facetCuts_.length,
            "Unexecptedd quantity of declared facet cuts."
        );
        for(uint256 facetCutCursor = 0; facetCutCursor < facetCuts_.length; facetCutCursor++) {
            control_IDiamondPackage_facetAddrressesOf_facetCuts
                [address(subject)]._add(facetCuts_[facetCutCursor].facetAddress);
            assertTrue(
                expected_IDiamondPackage_facetAddrressesOf_facetCuts
                    [address(subject)]
                    ._contains(facetCuts_[facetCutCursor].facetAddress),
                // TODO add test value logging.
                "Unexpected facet address declared in facet cut."
            );
            for(
                uint256 facetCutFuncsCursor = 0; 
                facetCutFuncsCursor < facetCuts_[facetCutCursor].functionSelectors.length; 
                facetCutFuncsCursor++
            ) {
                control_IDiamondPackage_facetFuncsOf_facetCuts
                    [address(subject)]
                    [facetCuts_[facetCutCursor].facetAddress]
                    ._add(facetCuts_[facetCutCursor].functionSelectors[facetCutFuncsCursor]);
                assertTrue(
                    expected_IDiamondPackage_facetFuncsOf_facetCuts
                        [address(subject)]
                        [facetCuts_[facetCutCursor].facetAddress]
                        ._contains(facetCuts_[facetCutCursor].functionSelectors[facetCutFuncsCursor])
                );
            }
            assertEq(
                facetCuts_[facetCutCursor].functionSelectors.length,
                control_IDiamondPackage_facetFuncsOf_facetCuts
                    [address(subject)]
                    [facetCuts_[facetCutCursor].facetAddress]._length(),
                // TODO add test value logging.
                "Duplicate functions declared for the same facet."
            );
        }
        uint256 controlFacetAddrLen_ = control_IDiamondPackage_facetAddrressesOf_facetCuts
                [address(subject)]._length();
        assertEq(
            facetCuts_.length,
            controlFacetAddrLen_,
            // TODO add flag to disable
            "Duplicate facet cut adddresses declared. While not required, optimal usage should consolidate declarations. *TODO* implement a flag to disable"
        );
        // vm.revertToState(snapShot);
    }

    function validate_IDiamondPackage_facetCuts(IDiamondPackage subject)
    public {
        validate_IDiamondPackage_facetCuts(
            subject,
            IDiamondPackage(address(subject)).facetCuts()
        );
    }

    function validate_IDiamondPackage_diamondConfig(IDiamondPackage subject)
    public {
        IDiamondPackage.DiamondConfig memory config_ = subject.diamondConfig();
        validate_IDiamondPackage_facetInterfaces(
            subject, 
            config_.interfaces
        );
        validate_IDiamondPackage_facetCuts(
            subject,
            config_.facetCuts_
        );
    }

    function validate_IDiamondPackage(IDiamondPackage subject)
    public {
        // uint256 snapShot = vm.snapshotState();
        validate_IDiamondPackage_facetInterfaces(subject);
        // vm.revertToState(snapShot);
        validate_IDiamondPackage_facetCuts(subject);
        // vm.revertToState(snapShot);
        validate_IDiamondPackage_diamondConfig(subject);
        // vm.revertToState(snapShot);
    }

}