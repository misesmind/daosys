// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "daosys/context/erc2535/interfaces/IFacet.sol";

/**
 * @title Facet - Inheritable exposure of IFacet functions.
 * @author cyotee doge <doge.cyotee>
 */
abstract contract Facet is IFacet {

    /**
     * @inheritdoc IFacet
     */
    function suppoertedInterfaces()
    public view virtual returns(bytes4[] memory interfaces);

    /**
     * @inheritdoc IFacet
     */
    function facetFuncs()
    public view virtual returns(bytes4[] memory funcs);

}