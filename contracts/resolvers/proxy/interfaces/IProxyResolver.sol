// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IProxyResolver {

    function initAccount()
    external returns(bool success);

    function getTarget(
        bytes4 functionSelector
    ) external view returns(address target_);

}