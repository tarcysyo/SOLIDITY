// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract D {
    uint public x;
    constructor(uint a) {
        x = a;
    }
}

contract C2 {
    function createDSalted(bytes32 salt, uint arg) public {
        address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(abi.encodePacked(type(D).creationCode, arg)))))));

        D d = new D{salt: salt}(arg);
        require(address(d) == predictedAddress);
    }
}