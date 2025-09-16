// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Storage {
    uint8 a;
    uint16 b;
    uint8 c;

    constructor(uint8 _a, uint16 _b, uint8 _c) {
        a = _a;
        b = _b;
        c = _c;
    }
}