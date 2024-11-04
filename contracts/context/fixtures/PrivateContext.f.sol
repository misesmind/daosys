// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/context/types/Context.sol";
import "daosys/context/types/PrivateContext.sol";

contract PrivateContextDeploymentFixture {

    PrivateContext internal _pachiraContext;

    function privateContext(
        IContext context_,
        address owner,
        string memory name
    )
    public returns(PrivateContext pachiraContext_) {
        if(address(_pachiraContext) == address(0)) {
            _pachiraContext = PrivateContext(
                context_
                    .deployContract(
                        type(PrivateContext).creationCode,
                        abi.encode(
                            owner,
                            name
                        )
                    )
            );
        }
        return _pachiraContext;
    }

}