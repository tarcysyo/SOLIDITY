// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

contract Test2 {
    fallback() external {
        x = 1;
    }
    uint x;
}

contract TestPayable {
    fallback() external payable {
        x = 1; 
        y = msg.value;
    }

    receive() external payable {
        x = 2;
        y = msg.value;
    }

    uint x;
    uint y;
}

contract caller {
    function callTest(Test2 test) public returns (bool) {
        (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        address payable testPayable = payable(address(test));

        return testPayable.send(2 ether);
    }

    function callTestPayable(TestPayable test) public returns (bool) {
        (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        (success,) = address(test).call{value: 1}(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        require(payable(test).send(2 ether));

        return true;
    }

}

