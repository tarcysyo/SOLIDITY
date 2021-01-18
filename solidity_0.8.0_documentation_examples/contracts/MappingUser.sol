// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract MappingUser {
    function f() public returns (uint){
        MappingExample2 m = new MappingExample2();
        m.update(100);
        return m.balances(address(this));
    }
}

contract MappingExample2 {
    mapping(address => uint) public balances;

    function update(uint newBalance) public {
        balances[msg.sender] = newBalance;
    }
}