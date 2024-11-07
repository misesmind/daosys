// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/dcdi/aware/types/DCDIAware.sol";
import "daosys/dcdi/context/erc2535/types/Facet.sol";
import "daosys/dcdi/context/interfaces/IContext.sol";
import "daosys/access/operatable/types/OperatableModifiers.sol";

contract ContextOperatorTarget
is
OperatableModifiers,
DCDIAware
{

    // /**
    //  * @inheritdoc IDCDI
    //  */
    // function supportedInterfaces()
    // public view virtual override returns(bytes4[] memory interfaces) {
    //     interfaces = new bytes4[](1);
    //     interfaces[0] = type(IContext).interfaceId;
    // }

    // /**
    //  * @inheritdoc IFacet
    //  */
    // function facetFuncs()
    // public view virtual override returns(bytes4[] memory funcs) {
    //     funcs = new bytes4[](4);
    //     funcs[0] = IContext.deployContract.selector;
    //     funcs[1] = IContext.deployWithIniter.selector;
    // }

    function context()
    public view virtual returns(IContext) {
        return IContext(origin());
    }

    function deployContract(
        bytes memory initCode_,
        bytes memory initData_
    ) external
    onlyOwnerOrOperator(msg.sender)
    returns(address deployment) {
        return context()
            .deployContract(
                initCode_,
                initData_
            );
    }

    function deployWithIniter(
        IContextInitializer initer,
        IPackage pkg,
        bytes memory pkgArgs
    ) external
    onlyOwnerOrOperator(msg.sender)
    returns(address deployment) {
        return context()
            .deployWithIniter(
                initer,
                pkg,
                pkgArgs
            );
    }
    
}