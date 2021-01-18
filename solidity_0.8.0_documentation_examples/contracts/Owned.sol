// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

contract Owned {
    constructor() {
        owner = payable(msg.sender);
    }
    address payable owner;
}

contract Destructible2 is Owned {
    function destroy() public virtual {
        if (msg.sender == owner)
            selfdestruct(owner);
    }
}

abstract contract Config {
    function lookup(uint id) public virtual returns (address adr);
}

abstract contract NameReg {
    function register(bytes32 name) public virtual;
    function unregister() public virtual;
}

contract Named is Owned, Destructible2 {
    constructor(bytes32 name) {
        Config config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
        NameReg(config.lookup(1)).register(name);
    }

    function destroy() public virtual override {
        if (msg.sender == owner) {
            Config config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
            NameReg(config.lookup(1)).unregister();
            Destructible2.destroy();
        }
    }
}

contract PriceFeed is Owned, Destructible2, Named ("GoldFeed") {
    function updateInfo(uint newInfo) public {
        if (msg.sender == owner)
            info = newInfo;
    }

    function destroy() public override (Destructible2, Named) {
        Named.destroy();
    }

    function get() public view returns (uint r) {
        return info;
    }

    uint info;
}