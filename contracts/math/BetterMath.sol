// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "daosys/Constants.sol";

struct Uint512 {
    uint256 hi; // 256 most significant bits
    uint256 lo; // 256 least significant bits
}

/**
 * @dev A proper math lib.
 */
library BetterMath {

    using BetterMath for uint256;

    /* ---------------------------------------------------------------------- */
    /*                                Constants                               */
    /* ---------------------------------------------------------------------- */

    uint8 constant ERC20_DEFAULT_DECIMALS = 18;
    uint224 constant Q112 = 2**112;

    /* ---------------------------------------------------------------------- */
    /*                                 Errors                                 */
    /* ---------------------------------------------------------------------- */

    error Overflow();
  
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    /* ---------------------------------------------------------------------- */
    /*                                 Structs                                */
    /* ---------------------------------------------------------------------- */

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /* ---------------------------------------------------------------------- */
    /*                              Unsigned Math                             */
    /* ---------------------------------------------------------------------- */

    /**
     * @dev Returns the largest of two numbers.
     */
    function _max(
        uint256 a,
        uint256 b
    ) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function _min(
        uint256 a,
        uint256 b
    ) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function _average(
        uint256 a,
        uint256 b
    ) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function _ceilDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function _mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = _mulDiv(x, y, denominator);
        if (_unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return _min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (_unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (_unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (_unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (_unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /* ---------------------------------------------------------------------- */
    /*                          Unsafe Unsigned Math                          */
    /* ---------------------------------------------------------------------- */

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function _tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function _trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function _tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function _tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function _tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /* ---------------------------------------------------------------------- */
    /*                               Signed Math                              */
    /* ---------------------------------------------------------------------- */

    /**
     * @dev Returns the largest of two signed numbers.
     */
    function _max(
        int256 a,
        int256 b
    ) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function _min(
        int256 a,
        int256 b
    ) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function _average(
        int256 a,
        int256 b
    ) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function _abs(
        int256 n
    ) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function _unsignedRoundsUp(
        Rounding rounding
    ) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }

    function _proportionalSplit(
        uint256 ownedShares,
        uint256 totalShares,
        uint256 totalReserveA,
        uint256 totalReserveB
    ) internal pure returns(
        uint256 shareA,
        uint256 shareB
    ) {
        shareA = ((ownedShares * totalReserveA) / totalShares);
        shareB = ((ownedShares * totalReserveB) / totalShares);
    }

    /* ---------------------------------------------------------------------- */
    /*                          Percentage Operations                         */
    /* ---------------------------------------------------------------------- */

    /**
     * @dev Expects percentage to be trailed by 0,
     */
    // 1 = 0.1%
    // 3 = 0.3%
    // 10 = 1%
    // 30 = 3%
    // 50 = 5%
    // 100 = 10%
    function _percentageAmount(uint256 total_, uint256 percentage_)
    internal pure returns ( uint256 percentAmount_ ) {
        return ( ( total_ * percentage_ ) / 1000 );
    }

    /**
     * @dev Expects percentage to be trailed by 000,
     */
    // 10 = 0.01%
    // 30 = 0.03%
    // 100 = 0.1%
    // 300 = 0.3%
    // 1000 = 1%
    // 3000 = 3%
    // 5000 = 5%
    // 10000 = 10%
    function _percentageAmountExpanded(uint256 total_, uint256 percentage_)
    internal pure returns ( uint256 percentAmount_ ) {
        return ( ( total_ * percentage_ ) / 100000 );
    }

    function _percentageOfTotalExpanded(uint256 part_, uint256 total_)
    internal pure returns ( uint256 percent_ ) {
        return ( (part_ * 100000) / total_ );
    }

    function _convertDecimalsFromTo(
        uint256 amount,
        uint8 amountDecimals,
        uint8 targetDecimals
    ) internal pure returns(uint256 convertedAmount) {
        if(amountDecimals == targetDecimals) {
            return amount;
        }
        convertedAmount = amountDecimals > targetDecimals
            ? amount / 10**(amountDecimals - targetDecimals)
            : amount * 10**(targetDecimals - amountDecimals);
    }

    function _precision(
        uint256 value,
        uint8 precision,
        uint8 targetPrecision
    ) internal pure returns(uint256 preciseValue) {
        preciseValue = value._convertDecimalsFromTo(
            precision,
            targetPrecision
        );
    }

    function _normalize(
        uint256 value
    ) internal pure returns(uint256) {
        return value._precision(ERC20_DEFAULT_DECIMALS, 2);
    }

    // function _min(uint256 a, uint256 b)
    // internal pure returns (uint256) {
    //     return a < b ? a : b;
    // }

    function _asc(uint256 a, uint256 b)
    internal pure returns(uint256 min, uint256 max) {
        require(a != b);
        min = a._min(b);
        max = min == a
        ? b
        : a;
    }

    function _diff(uint256 a, uint256 b)
    internal pure returns(uint256 diff) {
        (uint256 min, uint256 max) = a._asc(b);
        return max - min;
    }

    function _mod(
        uint256 a,
        uint256 b
    ) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    function _safeHalf(
        uint256 value
    ) internal pure returns(uint256 safeHalf) {
        safeHalf = value / 2;
        if(value._mod(2) == 0) {
            return safeHalf;
        }
        return value - safeHalf;
    }

    function _sqrt(uint256 x)
    internal pure returns (uint z) {
        assembly {
            // Start off with z at 1.
            z := 1

            // Used below to help find a nearby power of 2.
            let y := x

            // Find the lowest power of 2 that is at least sqrt(x).
            if iszero(lt(y, 0x100000000000000000000000000000000)) {
                y := shr(128, y) // Like dividing by 2 ** 128.
                z := shl(64, z) // Like multiplying by 2 ** 64.
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) // Like dividing by 2 ** 64.
                z := shl(32, z) // Like multiplying by 2 ** 32.
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) // Like dividing by 2 ** 32.
                z := shl(16, z) // Like multiplying by 2 ** 16.
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) // Like dividing by 2 ** 16.
                z := shl(8, z) // Like multiplying by 2 ** 8.
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) // Like dividing by 2 ** 8.
                z := shl(4, z) // Like multiplying by 2 ** 4.
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) // Like dividing by 2 ** 4.
                z := shl(2, z) // Like multiplying by 2 ** 2.
            }
            if iszero(lt(y, 0x8)) {
                // Equivalent to 2 ** z.
                z := shl(1, z)
            }

            // Shifting right by 1 is like dividing by 2.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // Compute a rounded down version of z.
            let zRoundDown := div(x, z)

            // If zRoundDown is smaller, use it.
            if lt(zRoundDown, z) {
                z := zRoundDown
            }
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function _mulDiv(
        uint256 x, 
        uint256 y, 
        uint256 denominator, 
        Rounding rounding
    )
    internal pure returns (uint256) {
        uint256 result = _mulDiv(x, y, denominator);
        if (_unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    // /**
    //  * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    //  * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
    //  * with further edits by Uniswap Labs also under MIT license.
    //  */
    // function _mulDiv(uint256 x, uint256 y, uint256 denominator)
    // internal pure returns (uint256 result) {
    //     unchecked {
    //         // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
    //         // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
    //         // variables such that product = prod1 * 2^256 + prod0.
    //         uint256 prod0 = x * y; // Least significant 256 bits of the product
    //         uint256 prod1; // Most significant 256 bits of the product
    //         assembly {
    //             let mm := mulmod(x, y, not(0))
    //             prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    //         }

    //         // Handle non-overflow cases, 256 by 256 division.
    //         if (prod1 == 0) {
    //             // Solidity will revert if denominator == 0, unlike the div opcode on its own.
    //             // The surrounding unchecked block does not change this fact.
    //             // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
    //             return prod0 / denominator;
    //         }

    //         // Make sure the result is less than 2^256. Also prevents denominator == 0.
    //         if (denominator <= prod1) {
    //             revert MathOverflowedMulDiv();
    //         }

    //         ///////////////////////////////////////////////
    //         // 512 by 256 division.
    //         ///////////////////////////////////////////////

    //         // Make division exact by subtracting the remainder from [prod1 prod0].
    //         uint256 remainder;
    //         assembly {
    //             // Compute remainder using mulmod.
    //             remainder := mulmod(x, y, denominator)

    //             // Subtract 256 bit number from 512 bit number.
    //             prod1 := sub(prod1, gt(remainder, prod0))
    //             prod0 := sub(prod0, remainder)
    //         }

    //         // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
    //         // See https://cs.stackexchange.com/q/138556/92363.

    //         uint256 twos = denominator & (0 - denominator);
    //         assembly {
    //             // Divide denominator by twos.
    //             denominator := div(denominator, twos)

    //             // Divide [prod1 prod0] by twos.
    //             prod0 := div(prod0, twos)

    //             // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
    //             twos := add(div(sub(0, twos), twos), 1)
    //         }

    //         // Shift in bits from prod1 into prod0.
    //         prod0 |= prod1 * twos;

    //         // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
    //         // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
    //         // four bits. That is, denominator * inv = 1 mod 2^4.
    //         uint256 inverse = (3 * denominator) ^ 2;

    //         // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
    //         // in modular arithmetic, doubling the correct bits in each step.
    //         inverse *= 2 - denominator * inverse; // inverse mod 2^8
    //         inverse *= 2 - denominator * inverse; // inverse mod 2^16
    //         inverse *= 2 - denominator * inverse; // inverse mod 2^32
    //         inverse *= 2 - denominator * inverse; // inverse mod 2^64
    //         inverse *= 2 - denominator * inverse; // inverse mod 2^128
    //         inverse *= 2 - denominator * inverse; // inverse mod 2^256

    //         // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
    //         // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
    //         // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
    //         // is no longer required.
    //         result = prod0 * inverse;
    //         return result;
    //     }
    // }

    function _mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            // Divide z by the denominator.
            z := div(z, denominator)
        }
    }

    function _mulWadDown(uint256 x, uint256 y)
    internal pure returns (uint256) {
        return _mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function _divWadDown(uint256 x, uint256 y)
    internal pure returns (uint256) {
      // require( (y != 0), "FixedPointWadMathLib:_divWadDown:: Attempting to divide by 0");
      return _mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    // /**
    //  * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
    //  */
    // function _unsignedRoundsUp(Rounding rounding)
    // internal pure returns (bool) {
    //     return uint8(rounding) % 2 == 1;
    // }

    /**
     * @dev returns the value of `x * y`
     */
    function _mul512(uint256 x, uint256 y)
    internal pure returns (Uint512 memory) {
        uint256 p = _mulModMax(x, y);
        uint256 q = _unsafeMul(x, y);
        if (p >= q) {
            return Uint512({hi: p - q, lo: q});
        }
        return Uint512({hi: _unsafeSub(p, q) - 1, lo: q});
    }

    /**
     * @dev returns `x * y % (2 ^ 256 - 1)`
     */
    function _mulModMax(uint256 x, uint256 y)
    private pure returns (uint256) {
        return mulmod(x, y, type(uint256).max);
    }

    /**
     * @dev returns `(x * y) % 2 ^ 256`
     */
    function _unsafeMul(uint256 x, uint256 y)
    private pure returns (uint256) {
        unchecked {
            return x * y;
        }
    }

    /**
     * @dev returns `(x - y) % 2 ^ 256`
     */
    function _unsafeSub(uint256 x, uint256 y)
    private pure returns (uint256) {
        unchecked {
            return x - y;
        }
    }

    function _div256(Uint512 memory x, uint256 y)
    internal pure returns (uint256) {
        if (x.hi == 0) {
            return x.lo / y;
        }

        if (x.hi >= y) {
            revert Overflow();
        }

        uint256 p = _unsafeSub(0, y) & y; // `p` is the largest power of 2 which `z` is divisible by
        uint256 q = _div512(x, p); // `n` is divisible by `p` because `n` is divisible by `z` and `z` is divisible by `p`
        uint256 r = _inv256(y / p); // `z / p = 1 mod 2` hence `inverse(z / p) = 1 mod 2 ^ 256`
        return _unsafeMul(q, r); // `q * r = (n / p) * inverse(z / p) = n / z`
    }

    /**
     * @dev returns the value of `x / pow2n`, given that `x` is divisible by `pow2n`
     */
    function _div512(Uint512 memory x, uint256 pow2n)
    internal pure returns (uint256) {
        uint256 pow2nInv = _unsafeAdd(_unsafeSub(0, pow2n) / pow2n, 1); // `1 << (256 - n)`
        return _unsafeMul(x.hi, pow2nInv) | (x.lo / pow2n); // `(x.hi << (256 - n)) | (x.lo >> n)`
    }

    /**
     * @dev returns the inverse of `d` modulo `2 ^ 256`, given that `d` is congruent to `1` modulo `2`
     */
    function _inv256(uint256 d)
    private pure returns (uint256) {
        // approximate the root of `f(x) = 1 / x - d` using the newton–raphson convergence method
        uint256 x = 1;
        for (uint256 i = 0; i < 8; i++) {
            x = _unsafeMul(x, _unsafeSub(2, _unsafeMul(x, d))); // `x = x * (2 - x * d) mod 2 ^ 256`
        }
        return x;
    }

    /**
     * @dev returns `(x + y) % 2 ^ 256`
     */
    function _unsafeAdd(uint256 x, uint256 y)
    private pure returns (uint256) {
        unchecked {
            return x + y;
        }
    }

    /* ---------------------------------------------------------------------- */
    /*                                UQ112x112                               */
    /* ---------------------------------------------------------------------- */

    // encode a uint112 as a UQ112x112
    function _encode(uint112 y)
    internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function _uqdiv(uint224 x, uint112 y)
    internal pure returns (uint224 z) {
        z = x / uint224(y);
    }

}