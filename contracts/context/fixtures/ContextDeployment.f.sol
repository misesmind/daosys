// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/context/types/Context.sol";

contract ContextDeploymentFixture {

    Context internal _context;

    function context()
    public virtual returns(Context context_) {
        if(address(_context) != address(0)) {
            return _context;
        }
        _context = new Context();
    }

}