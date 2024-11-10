// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title IERC165Enumerated = Enumeration of ALL implemented ERC165 interface IDs.
 * @author cyotee doge <doge.cyotee>
 */
interface IERC165Enumerated {

    /**
     * @dev ONLY includes interfaces epected to called directly.
     * @dev DOES NOT include interfaces expected to be called through a proxy.
     * @return interfaces All ERC165 interface IDs of implemented interfaces.
     */
    function supportedInterfaces()
    external view returns(bytes4[] memory interfaces);

}