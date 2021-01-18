// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

interface DataFeed { 
    function getData(address token) external returns (uint value);
}

contract FeeConsumer {
    DataFeed feed;
    uint errorCount;
    function rate(address token) public returns (uint value, bool success) {
        require(errorCount < 10);
        try feed.getData(token) returns (uint v) {
            return (v, true);
        } catch Error(string memory /*reason*/) {
            errorCount++;
            return(0, false);
        } catch (bytes memory /*lowLevelData*/) {
            errorCount++;
            return(0, false);
        }
    }
}