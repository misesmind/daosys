// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/StdAssertions.sol";

import "daosys/primitives/Address.sol";
import "daosys/primitives/UInt.sol";

import "daosys/dcdi/interfaces/IDCDI.sol";

contract IDCDIBehavior
is
StdAssertions
{
    using Address for address;
    using UInt for uint256;

    /* ---------------------------------------------------------------------- */
    /*                                  IDCDI                                 */
    /* ---------------------------------------------------------------------- */

    /* ---------------------------- Expectations ---------------------------- */

    mapping(address subject => address origin) expected_IDCDI_origin;
    mapping(address subject => bytes32 initCodeHash) expected_IDCDI_initCodeHash;
    mapping(address subject => bytes32 salt) expected_IDCDI_salt;
    mapping(address subject => bytes32 initDataHash) expected_IDCDI_initData_hashed;

    /* ---------------------------- Declarations ---------------------------- */

    function declareExpectations_IDCDI(
        IDCDI subject,
        address origin_,
        bytes32 initCodeHash_,
        bytes32 initData_hash,
        bytes32 salt_
    ) public {
        expected_IDCDI_origin
            [address(subject)]
            = origin_;
        expected_IDCDI_initCodeHash
            [address(subject)]
            = initCodeHash_;
        expected_IDCDI_initData_hashed
            [address(subject)]
            = initData_hash;
        expected_IDCDI_salt
            [address(subject)]
            = salt_;
    }

    function declareExpectations_IDCDI(
        IDCDI subject,
        address origin_,
        bytes32 initCodeHash_,
        bytes32 initData_hash
    ) public {
        declareExpectations_IDCDI(
            subject,
            origin_,
            initCodeHash_,
            initData_hash,
            keccak256(
                abi.encode(
                    initCodeHash_,
                    initData_hash
                )
            )
        );
    }

    /* ----------------------------- Validations ---------------------------- */

    function validate_IDCDI_origin(IDCDI subject)
    public view {
        assertEq(
            expected_IDCDI_origin[address(subject)],
            subject.origin(),
            "Unexpected origin()"
        );
    }

    function validate_IDCDI_self(IDCDI subject)
    public view  {
        assertEq(
            address(subject),
            subject.self(),
            "Unexpected self()"
        );
    }

    function validate_IDCDI_initCodeHash(IDCDI subject)
    public view  {
        assertEq(
            expected_IDCDI_initCodeHash[address(subject)],
            subject.initCodeHash(),
            "Unexpected initCodeHash()"
        );
    }

    function validate_IDCDI_salt(IDCDI subject)
    public view  {
        assertEq(
            expected_IDCDI_salt[address(subject)],
            subject.salt(),
            "Unexpected salt()"
        );
    }

    function validate_IDCDI_metadata(IDCDI subject)
    public view  {
        IDCDI.Metadata memory metadata_ = subject.metadata();
        assertEq(
            expected_IDCDI_origin[address(subject)],
            metadata_.origin,
            "Unexpected IDCDI.Metadata.origin"
        );
        assertEq(
            expected_IDCDI_initCodeHash[address(subject)],
            metadata_.initCodeHash,
            "Unexpected IDCDI.Metadata.initCodeHash"
        );
        assertEq(
            expected_IDCDI_salt[address(subject)],
            metadata_.salt,
            "Unexpected IDCDI.Metadata.salt"
        );
    }

    function validate__IDCDI_initData(IDCDI subject)
    public view  {
        assertEq(
            expected_IDCDI_initData_hashed[address(subject)],
            keccak256(subject.initData()),
            "Unexpected initData()"
        );
    }

    function validate__IDCDI(IDCDI subject)
    public view  {
        validate_IDCDI_origin(subject);
        validate_IDCDI_self(subject);
        validate_IDCDI_initCodeHash(subject);
        validate_IDCDI_salt(subject);
        validate_IDCDI_metadata(subject);
        validate__IDCDI_initData(subject);
    }

}