// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Address} from "daosys/primitives/Address.sol";
import "daosys/dcdi/interfaces/IDCDI.sol";

library IDCDIAdaptor {

    using Address for address;

    function _postDeploy(
        IDCDI newDeployment
    ) internal {
        address(newDeployment)
            ._delegateCall(IDCDI.postDeploy.selector);
    }

}