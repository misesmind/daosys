// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract TokenWithStringCAPSSymbolMock {
    // solhint-disable var-name-mixedcase
    string public SYMBOL = "ABC";

    constructor(string memory s) {
        SYMBOL = s;
    }
}
