// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/access/ownable/types/OwnableTarget.sol";
import "daosys/context/erc2535/types/Facet.sol";
import "daosys/access/ownable/interfaces/IOwnableManager.sol";
import "daosys/access/ownable/types/OwnableManagerTarget.sol";

/**
 * @title OwnableManagerFacet - Facet for Diamonds expected to retain ownership of other contracts.
 * @author cyotee doge <doge.cyotee>
 * @notice Allows Diamond proxies to call IOwnable functions on other contracts.
 */
contract OwnableManagerFacet
is
OwnableManagerTarget,
Facet
{

    /**
     * @inheritdoc IFacet
     */
    function suppoertedInterfaces()
    public view virtual override returns(bytes4[] memory interfaces) {
        interfaces =  new bytes4[](1);
        interfaces[0] = type(IOwnableManager).interfaceId;
    }

    /**
     * @inheritdoc IFacet
     */
    function facetFuncs()
    public view virtual override returns(bytes4[] memory funcs) {
        funcs = new bytes4[](3);
        funcs[0] = IOwnableManager.transferOwnershipFor.selector;
        funcs[1] = IOwnableManager.acceptOwnershipFor.selector;
        funcs[2] = IOwnableManager.renounceOwnershipFor.selector;
    }

    // /**
    //  * @inheritdoc IOwnableManager
    //  */
    // function transferOwnershipFor(
    //     IOwnable subject,
    //     address proposedOwner_
    // ) public onlyOwner(msg.sender) returns(bool) {
    //     return subject.transferOwnership(proposedOwner_);
    // }

    // /**
    //  * @inheritdoc IOwnableManager
    //  */
    // function acceptOwnershipFor(IOwnable subject)
    // public onlyOwner(msg.sender) returns(bool) {
    //     return subject.acceptOwnership();
    // }

    // /**
    //  * @inheritdoc IOwnableManager
    //  */
    // function renounceOwnershipFor(IOwnable subject)
    // public onlyOwner(msg.sender) returns(bool) {
    //     return subject.renounceOwnership();
    // }

}