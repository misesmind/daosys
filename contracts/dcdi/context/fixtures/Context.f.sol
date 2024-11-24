// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "daosys/dcdi/context/types/Context.sol";

contract ContextFixture {

    Context internal _context;

    function context()
    public virtual returns(Context context_) {
        if(address(_context) == address(0)) {
            _context = new Context();
        }
        return _context;
    }

}