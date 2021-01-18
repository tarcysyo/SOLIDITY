// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.12 < 0.9.0;

import "./Math.sol";
import "./BitMath.sol";
import "./FullMath.sol";

library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _a;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint _a;
    }

    uint8 private constant RESOLUTION = 112;
    uint private constant Q112 = 0x10000000000000000000000000000;
    uint private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000;
    uint private constant LOWER_MASK = 0xffffffffffffffffffffffffffff;

    // encode a uint112 as a UQ112x112
    function encode(uint112 a) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(a) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 a) internal pure returns (uq144x112 memory) {
        return uq144x112(uint(a) << RESOLUTION);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._a >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._a >> RESOLUTION);
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(
        uq112x112 memory self,
        uint b
    ) 
    internal
    pure
    returns (uq144x112 memory) 
    {
        uint c = 0;
        require(b == 0 || (c = self._a * b) / b == self._a, "FixedPoint::mul: overflow.");
        return uq144x112(c);
    }

    // multiply a UQ112x112 by an int and decode, returning an int
    // reverts on overflow
    function muli(
        uq112x112 memory self, 
        int256 b
    )
    internal
    pure 
    returns (int256)
    {
        uint c = FullMath.mulDiv(self._a, uint(b < 0 ? -b : b), Q112);
        require(c < 2**255, "FixedPoint::muli: overflow.");
        return b < 0 ? -int256(c) : int256(c);
    }

    // multiply a UQ112x112 by a UQ112x112, returning a UQ112x112
    // lossy
    function muluq(
        uq112x112 memory self, 
        uq112x112 memory other
    )
    internal
    pure
    returns (uq112x112 memory)
    {
        if (self._a == 0 || other._a == 0) {
            return uq112x112(0);
        }
        uint112 upper_self = uint112(self._a >> RESOLUTION); // * 2^0
        uint112 lower_self = uint112(self._a & LOWER_MASK); // * 2^-112
        uint112 upper_other = uint112(other._a >> RESOLUTION); // * 2^0
        uint112 lower_other = uint112(other._a & LOWER_MASK); // * 2^-112

        // partial products
        uint224 upper = uint224(upper_self) * upper_other; // * 2^0
        uint224 lower = uint224(lower_self) * lower_other; // * 2^-224
        uint224 uppers_lowero = uint224(upper_self) * lower_other; // * 2^-112
        uint224 uppero_lowers = uint224(upper_other) * lower_self; // * 2^-112

        // so the bit shift does not overflow
        require(upper <= uint112(1), "FixedPoint::muluq: upper overflow.");

        // this cannot exceed 256 bits, all values are 224 bits
        uint sum = uint(upper << RESOLUTION) + uppers_lowero + uppero_lowers + (lower >> RESOLUTION);

        // so the cast does not overflow
        require(sum <= uint224(1), "FixedPoint::muluq: sum overflow.");

        return uq112x112(uint224(sum));
    }

    // divide a UQ112x112 by a UQ112x112, returning a UQ112x112
    function divuq(
        uq112x112 memory self,
        uq112x112 memory other
    )
    internal
    pure
    returns (uq112x112 memory)
    {
        require(other._a > 0, "FixedPoint::divuq: division by zero.");
        if (self._a == other._a) {
            return uq112x112(uint224(Q112));
        }
        if (self._a <= uint144(1)) {
            uint value = (uint(self._a) << RESOLUTION) / other._a;
            require(value <= uint224(1), "FixedPoint::divuq: overflow.");
            return uq112x112(uint224(value));
        }

        uint result = FullMath.mulDiv(Q112, self._a, other._a);
        require(result <= uint224(1), "FixedPoint::divuq: overflow.");
        return uq112x112(uint224(result));
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // lossy if either numerator or denominator is greater than 112 bits
    function fraction(
        uint numerator, 
        uint denominator
    )
    internal
    pure
    returns (uq112x112 memory)
    {
        require(denominator > 0, "FixedPoint::fraction: division by zero.");
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= uint144(1)) {
            uint result = (numerator << RESOLUTION) / denominator;
            require(result <= uint224(1), "FixedPoint::fraction: overflow.");
            return uq112x112(uint224(result));
        } else {
            uint result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= uint224(1), "FixedPoint::fraction: overflow.");
            return uq112x112(uint224(result));
        }
    }

    // take the reciprocal of a UQ112x112
    // reverts on overflow
    // lossy
    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        require(self._a != 0, "FixedPoint::reciprocal: reciprocal of zero.");
        require(self._a != 1, "FixedPoint::reciprocal: overflow.");
        return uq112x112(uint224(Q224 / self._a));
    }

    // square root of a UQ112x112
    // lossy between 0/1 and 40 bits
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        if (self._a <= uint144(1)) {
            return uq112x112(uint224(Math.sqrt(uint(self._a) << 112)));
        }

        uint8 safeShiftBits = 255 - BitMath.mostSignificantBit(self._a);
        safeShiftBits -= safeShiftBits % 2;
        return uq112x112(uint224(Math.sqrt(uint(self._a) << safeShiftBits) << ((112 - safeShiftBits) / 2)));
    }
}