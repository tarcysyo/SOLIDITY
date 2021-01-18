// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

import "./TokenCreator.sol";

contract OwnedToken {
    TokenCreator creator;
    address owner;
    bytes32 name;

    constructor(bytes32 _name) {
        owner = msg.sender;
        creator = TokenCreator(msg.sender);
        name = _name;
    }

    function changeName(bytes32 newName) public {
        if (msg.sender == address(creator))
            name = newName;
    }

    function transfer(address newOwner) public {
        if (msg.sender != owner) return;
        if (creator.isTokenTransferOK(owner, newOwner))
            owner = newOwner;
    }
}