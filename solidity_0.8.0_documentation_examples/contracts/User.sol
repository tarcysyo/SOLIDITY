// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./libraries/IterableMapping.sol";

contract User {
    itmap data;    
    using IterableMapping for itmap;

    function insert(uint k, uint v) public returns (uint size) {
        data.insert(k,v);
        return data.size;
    }

    function sum() public view returns (uint s) {
        for (uint i = data.iterate_start(); data.iterate_valid(i); i = data.iterate_next(i)) {
            (, uint value) = data.iterate_get(i);
            s += value;
        }
    }
}