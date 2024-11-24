// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract TokenWithStringSymbolMock {
    string public symbol = "ABC";

    constructor(string memory s) {
        symbol = s;
    }
}
