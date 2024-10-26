// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IDCDI} from "daosys/dcdi/interfaces/IDCDI.sol";
import {DCDIAwareService} from "daosys/dcdi/aware/libs/DCDIAwareService.sol";

abstract contract DCDIAware is IDCDI {

    using DCDIAwareService for address;
    using DCDIAwareService for IDCDI.Metadata;

    /*
    NOTE: Compiler does NOT consider immutable storage usage acceptable in pure functions.
     */

    // solhint-disable-next-line var-name-mixedcase
    // Embed origin for more gas efficient retrieval.
    address private immutable ORIGIN;

    // solhint-disable-next-line var-name-mixedcase
    // Embed own address to retrieval regardless of execution context.
    address private immutable SELF;

    // Embed init code hash for more gas efficient retrieval.
    bytes32 private immutable INIT_CODE_HASH;

    // Embed isalt for more gas efficient retrieval.
    bytes32 private immutable SALT;

    constructor() {
        // Embed the deployer address.
        ORIGIN = address(msg.sender);
        // Embed own address
        SELF = address(this);
        // Load the injected metadata struct.
        IDCDI.Metadata memory metadata_ = _origin()._queryMetadata(_self());
        // Validate loaded metadata is valid for this contract.
        require(_origin() == metadata_.origin);
        require(_self() == metadata_._calcAddress());
        // Embed init code hash in contract bytecode.
        INIT_CODE_HASH = metadata_.initCodeHash;
        // Embed CREATE2 salt in contract bytecode.
        SALT = metadata_.salt;
    }

    /**
     * @dev Normally loaded using DCDI and stored immutablly.
     * @dev MUST be consistent regardless of Execution Context.
     * @return initCodeHash_ The hash of the creation code used to deploy the exposing contract.
     */
    function _initCodeHash()
    internal view virtual returns(bytes32 initCodeHash_) {
        initCodeHash_ = INIT_CODE_HASH;
    }

    /**
     * @dev Normally loaded using DCDI and stored immutablly.
     * @dev MUST be consistent regardless of Execution Context.
     * @return salt_ The salt used to deploy the exposing contract with CREATE2.
     */
    function _salt()
    internal view virtual returns(bytes32 salt_) {
        salt_ = SALT;
    }

    /**
     * @inheritdoc IDCDI
     */
    function origin()
    public view virtual
    returns(address origin_) {
        origin_ = _origin();
    }

    /**
     * @dev MUST be consistent regardless of Execution Context.
     * @return origin_ The address that deployed the contract exposing this interface.
     */
    function _origin()
    internal view virtual
    returns(address origin_) {
        origin_ = ORIGIN;
    }

    /**
     * @inheritdoc IDCDI
     */
    function self()
    public view virtual
    returns(address self_) {
        self_ = _self();
    }

    /**
     * @dev MUST be consistent regardless of Execution Context.
     * @dev May be used when address is required for retrieving DCDI injected data.
     * @return self_ own address.
     */
    function _self()
    internal view virtual
    returns(address self_) {
        self_ = SELF;
    }

    /**
     * @inheritdoc IDCDI
     */
    function initCodeHash()
    public view
    returns(bytes32 initCodeHash_) {
        initCodeHash_ = _initCodeHash();
    }

    /**
     * @inheritdoc IDCDI
     */
    function salt()
    public view
    returns(bytes32 salt_) {
        salt_ = _salt();
    }

    /**
     * @inheritdoc IDCDI
     */
    function metadata()
    public view
    returns(IDCDI.Metadata memory metadata_) {
        metadata_ = _metadata();
    }

    /**
     * @dev MUST be consistent regardless of Execution Context.
     * @return metadata_ The full Metadata struct containing all CREATE2 variables used to deploy the exposing contract.
     */
    function _metadata()
    internal view
    returns(IDCDI.Metadata memory metadata_) {
        metadata_ = IDCDI.Metadata({
            origin: _origin(),
            initCodeHash: _initCodeHash(),
            salt: _salt()
        });
        // metadata_ = _origin()._queryMetadata(_self());
    }

    /**
     * @return initData_ The data injected to initialize this contract.
     */
    function _initData()
    internal view returns(bytes memory initData_) {
        initData_ = _self()._queryInitData(
                origin(),
                initCodeHash(),
                salt()
            );
    }

    /**
     * @inheritdoc IDCDI
     */
    function initData()
    public view returns(bytes memory initData_) {
        initData_ = _initData();
    }

}