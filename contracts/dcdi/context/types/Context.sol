// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
import "forge-std/console.sol";
// import "forge-std/console2.sol";


import "daosys/dcdi/context/interfaces/IContext.sol";
import "daosys/dcdi/context/initializers/interfaces/IContextInitializer.sol";
import "daosys/dcdi/context/initializers/libs/ContextInitializerAdaptor.sol";
import "daosys/dcdi/factory/libs/DCDIFactoryService.sol";
import "daosys/introspection/erc165/mutable/types/MutableERC165Target.sol";
import "daosys/dcdi/interfaces/IDCDI.sol";
import "daosys/dcdi/aware/libs/IDCDIAdaptor.sol";

/**
 * @title Context - Extendable arbitrary deployment factory.
 * @author cyotee doge <doge.cyotee>
 * @notice Allows anyone to deploy bytecode to a deterministic address.
 * @notice Provides a hookable deployment process to extend functionality.
 */
contract Context
is
MutableERC165Target,
IDCDI,
IContext
{

    using ContextInitializerAdaptor for IContextInitializer;
    using DCDIFactoryService for bytes;
    using IDCDIAdaptor for IDCDI;

    address immutable ORIGIN;
    address immutable SELF;

    constructor() {
        ORIGIN = msg.sender;
        SELF = address(this);
        _initERC165(supportedInterfaces());
    }

    /**
     * @inheritdoc IDCDI
     */
    function origin()
    public view virtual returns(address origin_) {
        return ORIGIN;
    }

    /**
     * @inheritdoc IDCDI
     */
    function self()
    public view virtual returns(address self_) {
        return SELF;
    }

    /**
     * @inheritdoc IDCDI
     */
    function initCodeHash()
    public view virtual returns(bytes32 initCodeHash_) {
        return bytes32(0);
    }

    /**
     * @inheritdoc IDCDI
     */
    function salt()
    public view virtual returns(bytes32 salt_) {
        return bytes32(0);
    }

    /**
     * @return metadata_ The full Metadata struct containing all CREATE2 variables used to deploy the exposing contract.
     */
    function metadata()
    public view virtual returns(IDCDI.Metadata memory metadata_) {
        return Metadata({
            origin: origin(),
            initCodeHash: initCodeHash(),
            salt: salt()
        });
    }

    /**
     * @return initData_ The data injected to initialize the contract exposing this interface.
     */
    function initData()
    public view virtual returns(bytes memory initData_) {
        return "";
    }

    function supportedInterfaces()
    public view virtual returns(bytes4[] memory interfaces) {
        interfaces = new bytes4[](3);
        interfaces[0] = type(IERC165).interfaceId;
        interfaces[1] = type(IDCDI).interfaceId;
        interfaces[2] = type(IContext).interfaceId;
    }

    /**
     * @inheritdoc IContext
     */
    function deployContract(
        bytes memory initCode_,
        bytes memory initData_
    ) public virtual
    returns(address deployment) {
        deployment = initCode_._deploySelfIDInjection(initData_);
    }

    /**
     * @inheritdoc IContext
     */
    function deployWithIniter(
        IContextInitializer initer,
        IPackage pkg,
        bytes memory pkgArgs
    ) public virtual
    returns(address deployment) {
        (
            bytes memory initCode_,
            bytes32 salt_,
            bytes memory initData_
        ) = initer._initContext(
            pkg,
            pkgArgs
        );

        deployment = initCode_
            ._create2WithInjection(
            // bytes memory initCode,
            // bytes32 salt,
            salt_,
            // bytes memory initData
            initData_
        );
    }

    function postDeploy()
    public virtual override(IDCDI, IContext) returns(bool) {
        IDCDI(msg.sender)._postDeploy();
        return true;
    }

}