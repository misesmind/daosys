// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IERC721} from "./IERC721.sol";

interface IERC721Enumerated is IERC721 {

    function ownedIds(address account)
    external view returns(uint256[] memory);

}