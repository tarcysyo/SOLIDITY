// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract OwnedDest {
    constructor(){
        owner = payable(msg.sender);
    }
    address payable owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }
}

contract Destructible is OwnedDest {
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
}

contract Priced {
    modifier costs(uint price) {
        if (msg.value >= price) {
            _;
        }
    }
}

contract Register is Priced, Destructible {
    mapping(address => bool) registeredAddresses;
    uint price;

    constructor(uint initialPrice) {
        price = initialPrice;
    }

    function register() public payable costs(price) {
        registeredAddresses[msg.sender] = true;
    }

    function changePrice(uint _price) public onlyOwner {
        price = _price;
    }
}

contract Mutex {
    bool locked;
    modifier noReentrancy() {
        require(!locked, "Reentrant call.");
        locked = true;
        _;
        locked = false;
    }

    /// This function is protected by a mutex, which means that
    /// reentrant calls from within `msg.sender.call` cannot call `f` again.
    /// The `return 7` statement assigns 7 to the return value but still
    /// executes the statement `locked = false` in the modifier.
    function f() public noReentrancy returns (uint) {
        (bool success,) = msg.sender.call("");
        require(success);
        return 7;
    }
}