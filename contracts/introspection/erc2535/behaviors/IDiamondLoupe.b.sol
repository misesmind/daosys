// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/test/vm/VMAware.sol";
import "forge-std/StdAssertions.sol";

import "daosys/primitives/Address.sol";
import "daosys/primitives/UInt.sol";
import "daosys/collections/sets/AddressSetRepo.sol";
import "daosys/collections/sets/Bytes4SetRepo.sol";

import "daosys/introspection/erc2535/interfaces/IDiamondLoupe.sol";

contract IDiamondLoupeBehavior
is
VMAware,
StdAssertions
{
    using Address for address;
    using AddressSetRepo for AddressSet;
    using Bytes4SetRepo for Bytes4Set;
    using UInt for uint256;

    /* ---------------------------- Expectations ---------------------------- */

    mapping(address facet => Bytes4Set facetFuncs)
        control_IDiamondLoupe_facetFunctionSelectors;
    mapping(address subject => mapping(address facet => Bytes4Set facetFuncs))
        expected_IDiamondLoupe_facetFunctionSelectors;

    mapping(address subject => AddressSet facetAddresses)
        test_IDiamondLoupe_facetAddresses;
    mapping(address subject => AddressSet facetAddresses)
        expected_IDiamondLoupe_facetAddresses;

    mapping(address subject => mapping(bytes4 func => address facetAddress))
        expected_IDiamondLoupe_facetAddress;

    /* ---------------------------- Declarations ---------------------------- */

    function declareExpectations_IDiamondLpoue_facetAddresses(
        IDiamondLoupe subject,
        address facetAddress
    ) public {
        expected_IDiamondLoupe_facetAddresses[address(subject)]
        ._add(facetAddress);
    }

    function declareExpectations_IDiamondLpoue_facetAddresses(
        IDiamondLoupe subject,
        address[] memory facetAddresses
    ) public {
        expected_IDiamondLoupe_facetAddresses[address(subject)]
        ._add(facetAddresses);
    }

    function declareExpectations_IDiamondLoupe_controlFacet(
        address facet,
        bytes4[] memory facetFuncs
    ) public {
        control_IDiamondLoupe_facetFunctionSelectors
            [facet]
            ._add(facetFuncs);
    }

    function declareExpectations_IDiamondLoupe_facetFunctionSelectors(
        IDiamondLoupe subject,
        address facet,
        bytes4[] memory facetFuncs
    ) public {
        expected_IDiamondLoupe_facetFunctionSelectors[address(subject)]
            [address(facet)]
            ._add(facetFuncs);
    }

    function declare_IDiamondLoupe_facetAddress(
        IDiamondLoupe subject,
        address facet,
        bytes4[] memory facetFuncs
    ) public {
        for(uint256 cursor = 0; cursor < facetFuncs.length; cursor ++) {
            expected_IDiamondLoupe_facetAddress[address(subject)]
                [facetFuncs[cursor]] = address(facet);
        }
    }

    /* ----------------------------- Validations ---------------------------- */
    function validate_IDiamondLoupe(IDiamondLoupe subject)
    public {
        validate_IDiamondLoupe_facets(IDiamondLoupe(address((subject))));
        validate_IDiamondLoupe_facetAddresses(IDiamondLoupe(address((subject))));
        validate_IDiamondLoupe_facetAddress(IDiamondLoupe(address((subject))));
        validate_IDiamondLoupe_facetFunctionSelectors(IDiamondLoupe(address((subject))));
    }

    function validate_IDiamondLoupe_facets(IDiamondLoupe subject)
    public view {
        IDiamondLoupe.Facet[] memory test_facets_ = subject.facets();
        uint256 expectedLen = expected_IDiamondLoupe_facetAddresses[address(subject)]._length();
        assertEq(
            test_facets_.length,
            expectedLen,
            "Unexpected quantity of facets"
        );
        for(uint256 facets_cursor = 0; facets_cursor < test_facets_.length; facets_cursor++) {
            assertTrue(
                expected_IDiamondLoupe_facetAddresses[address(subject)]
                    ._contains(test_facets_[facets_cursor].facetAddress),
                string.concat(
                    "Unexpected facet declared.",
                    "Facet: ",
                    facets_cursor._toString(),
                    " Facet addressL ",
                    test_facets_[facets_cursor].facetAddress._toString()
                )
            );
            for(uint256 funcCursor = 0; funcCursor < test_facets_[facets_cursor].functionSelectors.length; funcCursor++) {
                assertTrue(
                    control_IDiamondLoupe_facetFunctionSelectors
                        [test_facets_[facets_cursor].facetAddress]
                        ._contains(test_facets_[facets_cursor].functionSelectors[funcCursor])
                );
            }
        }
    }

    function validate_IDiamondLoupe_facetFunctionSelectors(IDiamondLoupe subject)
    public view {
        AddressSet storage facetAddresses_ = expected_IDiamondLoupe_facetAddresses[address(subject)];
        for(uint256 faCursor = 0; faCursor < facetAddresses_._length(); faCursor++) {
            bytes4[] memory facetFunctionSelectors_ = IDiamondLoupe(address(subject))
                .facetFunctionSelectors(facetAddresses_._index(faCursor));
            for(uint256 funcCursor = 0; funcCursor < facetFunctionSelectors_.length; funcCursor++) {
                assertTrue(
                    control_IDiamondLoupe_facetFunctionSelectors
                        [facetAddresses_._index(faCursor)]
                        ._contains(facetFunctionSelectors_[funcCursor])
                );
            }
        }
    }

    function validate_IDiamondLoupe_facetAddresses(IDiamondLoupe subject)
    public dirtiesState() {
        address[] memory facetAddresses_ = IDiamondLoupe(address(subject)).facetAddresses();
        for(uint256 cursor = 0; cursor < facetAddresses_.length; cursor++) {
            assertTrue(
                expected_IDiamondLoupe_facetAddresses[address(subject)]._contains(facetAddresses_[cursor]),
                string.concat(
                    "Unexpected facet declared.",
                    "Facet: ",
                    cursor._toString(),
                    " Facet addressL ",
                    facetAddresses_[cursor]._toString()
                )
            );
        }
        uint256 expectedLen = expected_IDiamondLoupe_facetAddresses[address(subject)]._length();
        assertEq(
            facetAddresses_.length,
            expectedLen,
            "Unexpected quantity of facet addresses"
        );
        test_IDiamondLoupe_facetAddresses[address(subject)]._add(facetAddresses_);
        assertEq(
            facetAddresses_.length,
            test_IDiamondLoupe_facetAddresses[address(subject)]._length(),
            "Duplicate facet address declared."
        );
        for(uint256 cursor = 0; cursor < expectedLen; cursor++) {
            assertTrue(
                test_IDiamondLoupe_facetAddresses[address(subject)]
                    ._contains(
                        expected_IDiamondLoupe_facetAddresses[address(subject)]._index(cursor)
                    ),
                "Expected facet NOT declared."
            );
        }
    }

    function validate_IDiamondLoupe_facetAddress(IDiamondLoupe subject)
    public dirtiesState() {
        address[] memory test_facetAddresses_ = IDiamondLoupe(address(subject)).facetAddresses();
        for(uint256 facetCursor = 0; facetCursor < test_facetAddresses_.length; facetCursor++) {
            // IDiamondLoupe(address(subject))
            //     facetAddress(facetAddresses_[facetCursor])
            Bytes4Set storage controlFuncs = control_IDiamondLoupe_facetFunctionSelectors[test_facetAddresses_[facetCursor]];
            for(uint256 facetFuncCursor = 0; facetFuncCursor < controlFuncs._length(); facetFuncCursor++) {
                assertTrue(
                    expected_IDiamondLoupe_facetFunctionSelectors
                        [address(subject)]
                        [test_facetAddresses_[facetCursor]]
                        ._contains(controlFuncs._index(facetFuncCursor))
                );
            }
            // TODO consider more validation.
        }
        test_IDiamondLoupe_facetAddresses[address(subject)]._add(test_facetAddresses_);
        uint256 expectedLen = test_IDiamondLoupe_facetAddresses[address(subject)]._length();
        assertEq(
            expectedLen,
            test_facetAddresses_.length,
            "Declared facet addresses quantity mismatch."
        );
    }

}