// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

import "./Oracle.sol";

contract OracleUser {
    Oracle constant private ORACLE_CONST = Oracle (address(0x00000000219ab540356cBB839Cbe05303d7705Fa));
    uint private exchangeRate;

    function buySomething() public {
        ORACLE_CONST.query("USD", this.oracleResponse);
    }

    function oracleResponse(uint response) public {
        require(msg.sender == address(ORACLE_CONST), "Only oracle can call this.");
        exchangeRate = response;
    }
}