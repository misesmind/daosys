// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/dcdi/context/interfaces/IContext.sol";

interface IContextAware {

    /**
     * @return The Context instance from which this instance was deployed.
     */
    function context()
    external view returns(IContext);

}