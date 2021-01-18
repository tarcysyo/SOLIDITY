// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.12 < 0.9.0;

library Math {
    
    /// @dev Returns the smallest of two numbers.
    function min(
        uint a, 
        uint b
    ) 
    internal 
    pure 
    returns (uint) 
    {
        return a < b ? a : b;
    }

    /// @dev babylonian method 
    ///(https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint b) internal pure returns (uint c) {
        if (b > 3) {
            c = b;
            uint a = b / 2 + 1;
            while (a < c) {
                c = a;
                a = (b / a + a) / 2;
            }
        } else if (b != 0) {
            c = 1;
        }
    }
}