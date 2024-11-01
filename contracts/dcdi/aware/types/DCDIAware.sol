// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/dcdi/interfaces/IDCDI.sol";
import "daosys/dcdi/aware/libs/DCDIAwareService.sol";
import "daosys/introspection/erc165/mutable/types/MutableERC165Target.sol";

abstract contract DCDIAware
is
// MutableERC165Target,
IDCDI
{

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
        IDCDI.Metadata memory metadata_ = ORIGIN._queryMetadata(SELF);
        // Validate loaded metadata is valid for this contract.
        require(ORIGIN == metadata_.origin);
        require(SELF == metadata_._calcAddress());
        // Embed init code hash in contract bytecode.
        INIT_CODE_HASH = metadata_.initCodeHash;
        // Embed CREATE2 salt in contract bytecode.
        SALT = metadata_.salt;
        // _initERC165(supportedInterfaces());
    }

    /**
     * @inheritdoc IDCDI
     */
    function origin()
    public view virtual
    returns(address origin_) {
        return ORIGIN;
    }

    /**
     * @inheritdoc IDCDI
     */
    function self()
    public view virtual
    returns(address self_) {
        return SELF;
    }

    /**
     * @inheritdoc IDCDI
     */
    function initCodeHash()
    public view virtual
    returns(bytes32 initCodeHash_) {
        return INIT_CODE_HASH;
    }

    /**
     * @inheritdoc IDCDI
     */
    function salt()
    public view virtual
    returns(bytes32 salt_) {
        return SALT;
    }

    /**
     * @inheritdoc IDCDI
     */
    function metadata()
    public view virtual
    returns(IDCDI.Metadata memory metadata_) {
        return IDCDI.Metadata({
            origin: origin(),
            initCodeHash: initCodeHash(),
            salt: salt()
        });
    }

    /**
     * @inheritdoc IDCDI
     */
    function initData()
    public view virtual
    returns(bytes memory initData_) {
        // initData_ = initData();
        return self()._queryInitData(
                origin(),
                initCodeHash(),
                salt()
            );
    }

    // function supportedInterfaces()
    // public view virtual returns(bytes4[] memory interfaces) {
    //     interfaces = new bytes4[](2);
    //     interfaces[0] = type(IERC165).interfaceId;
    //     interfaces[1] = type(IDCDI).interfaceId;
    // }

}