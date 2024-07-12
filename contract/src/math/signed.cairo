use core::clone::Clone;
use core::option::OptionTrait;
use core::traits::TryInto;
use core::fmt::{Display, Formatter, Error};

// Implementations based on alexandria implementation : 
// https://github.com/keep-starknet-strange/alexandria/blob/main/packages/math/src/wad_ray_math.cairo

// -------------------------------------------------
// SIGNED ARITHMETIC
// -------------------------------------------------

pub trait ISignedBasics<T> {
    fn is_positive(self: @T) -> bool;
    fn abs(self: @T) -> T;

    fn as_unsigned(self: @T) -> u128;
    fn as_felt(self: @T) -> felt252;
    fn as_unsigned_felt(self: @T) -> felt252;
}

pub impl I128SignedBasics of ISignedBasics<i128> {
    fn is_positive(self: @i128) -> bool {
        *self >= 0_i128
    }

    fn as_unsigned(self: @i128) -> u128 {
        if self.is_positive() {
            (*self).try_into().unwrap()
        } else {
            (-1_i128 * *self).try_into().unwrap()
        }
    }

    fn as_felt(self: @i128) -> felt252 {
        (*self).try_into().unwrap()
    }

    fn as_unsigned_felt(self: @i128) -> felt252 {
        self.as_unsigned().try_into().unwrap()
    }

    fn abs(self: @i128) -> i128 {
        if self.is_positive() {
            *self
        } else {
            *self * -1_i128
        }
    }
}

pub impl I128Div of Div<i128> {
    fn div(lhs: i128, rhs: i128) -> i128 {
        let unsigned_div = unsigned_to_signed(@(lhs.as_unsigned() / rhs.as_unsigned()));
        let positive = lhs.is_positive() == rhs.is_positive();

        if positive {
            unsigned_div
        } else {
            unsigned_div * -1_i128
        }
    }
}

pub impl I128Display of Display<i128> {
    fn fmt(self: @i128, ref f: Formatter) -> Result<(), Error> {
        let sign: ByteArray = if self.is_positive() {
            ""
        } else {
            "-"
        };
        write!(f, "{}{}", sign, self.as_unsigned())
    }
}

pub fn unsigned_to_signed(x: @u128) -> i128 {
    (*x).try_into().unwrap()
}

pub fn felt_to_i128(x: @felt252) -> i128 {
    (*x).try_into().unwrap()
}
