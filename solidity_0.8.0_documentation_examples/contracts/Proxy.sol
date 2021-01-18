// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.8 <0.9.0;

contract Proxy {
    /// @dev Address of the client contract managed by proxy i.e., this contract
    address client;

    constructor(address _client) {
        client = _client;
    }

    /// Forward call to "setOwner(address)" that is implemented by client
    /// after doing basic validation on the address argument.
    function forward(bytes calldata _payload) external {
        bytes4 sig = _payload[0] | (bytes4 (_payload[1]) >> 8) | (bytes4 (_payload[2]) >> 16) | (bytes4 (_payload[3]) >> 24);
        if (sig == (keccak256("setOwner(address)"))) {
            address owner = abi.decode(_payload[4:], (address));
            require(owner != address(0), "Address of owner cannot be zero.");
        }
        (bool status,) = client.delegatecall(_payload);
        require(status, "Forwarded call failed.");
    }
}