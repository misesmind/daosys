// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
// import "forge-std/console.sol";
// import "forge-std/console2.sol";

import "daosys/dcdi/context/operatable/types/OperatableContext.sol";
import "daosys/dcdi/aware/types/DCDIAware.sol";
import "daosys/dcdi/context/interfaces/IPrivateContext.sol";
import "daosys/access/ownable/interfaces/IOwnable.sol";
import "daosys/access/operatable/interface/IOperatable.sol";

/**
 * @title PrivateContext - Nameable OperatableContext.
 * @author cyotee doge <doge.cyotee>
 * @dev MUST be deployed from another another Context.
 */
contract PrivateContext
is
OperatableContext,
DCDIAware,
IPrivateContext
{

    /**
     * @inheritdoc IPrivateContext
     */
    string public name;

    constructor() {
        (
            address owner_,
            string memory name_
        ) = abi.decode(
            initData(),
            (address, string)
        );
        _initOwner(owner_);
        name = name_;
    }

    /**
     * @inheritdoc IDCDI
     */
    function origin()
    public view virtual
    override(Context, DCDIAware)
    returns(address origin_) {
        return DCDIAware.origin();
    }

    /**
     * @inheritdoc IDCDI
     */
    function self()
    public view virtual
    override(Context, DCDIAware)
    returns(address self_) {
        return DCDIAware.self();
    }

    /**
     * @inheritdoc IDCDI
     */
    function initCodeHash()
    public view virtual
    override(Context, DCDIAware)
    returns(bytes32 initCodeHash_) {
        return DCDIAware.initCodeHash();
    }

    /**
     * @inheritdoc IDCDI
     */
    function salt()
    public view virtual
    override(Context, DCDIAware)
    returns(bytes32 salt_) {
        return DCDIAware.salt();
    }

    /**
     * @inheritdoc IDCDI
     */
    function metadata()
    public view virtual
    override(Context, DCDIAware)
    returns(IDCDI.Metadata memory metadata_) {
        return DCDIAware.metadata();
    }

    /**
     * @inheritdoc IDCDI
     */
    function initData()
    public view virtual
    override(Context, DCDIAware)
    returns(bytes memory initData_) {
        return DCDIAware.initData();
    }

    function supportedInterfaces()
    public view virtual override returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](4);
        interfaces[0] = type(IERC165).interfaceId;
        interfaces[1] = type(IContext).interfaceId;
        interfaces[2] = type(IOperatable).interfaceId;
        interfaces[3] = type(IOwnable).interfaceId;
    }

    function postDeploy()
    external virtual override(DCDIAware, Context) returns(bool) {}

    function postDeploy(
        address consumer_
    ) external returns(bool success) {
        return true;
    }

    
}