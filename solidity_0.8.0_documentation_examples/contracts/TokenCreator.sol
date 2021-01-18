// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

import "./OwnedToken.sol";

contract TokenCreator {
    function createToken(bytes32 name) public returns (OwnedToken tokenAddress) {
        return new OwnedToken(name);
    }

    function changeName(OwnedToken tokenAddress, bytes32 name) public {
        tokenAddress.changeName(name);
    }

    function isTokenTransferOK(address currentOwner, address newOwner) public pure returns (bool ok) {
        return keccak256(abi.encodePacked(currentOwner, newOwner))[0] == 0x7f;
    }
}