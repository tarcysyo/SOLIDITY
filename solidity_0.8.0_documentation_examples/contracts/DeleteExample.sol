// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract DeleteExample {
    uint data;
    uint[] dataArray;

    function f() public {
        uint x = data;
        delete x;
        delete data;
        uint[] storage y = dataArray;
        delete dataArray;
        assert(y.length == 0);
    }
}