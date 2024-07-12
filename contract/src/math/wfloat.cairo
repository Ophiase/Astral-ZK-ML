use core::clone::Clone;
use core::option::OptionTrait;
use core::traits::TryInto;
use core::fmt::{Display, Formatter, Error};

use super::signed::{
    ISignedBasics, I128SignedBasics, unsigned_to_signed, felt_to_i128, I128Div, I128Display,
};

use super::algebra::{NeutralElement, Invertible, pow, pow_group, pow_monoid};


// Implementations based on alexandria implementation : 
// https://github.com/keep-starknet-strange/alexandria/blob/main/packages/math/src/wad_ray_math.cairo
// https://github.com/keep-starknet-strange/alexandria/blob/main/packages/math/src/lib.cairo

// -------------------------------------------------
// WFLOAT ARITHMETIC
// -------------------------------------------------

#[derive(PartialEq, Drop, Copy, Hash, Serde, starknet::Store)]
pub struct WFloat {
    pub value: i128
}

pub const WFLOAT_POW: usize = 6;
pub const NEG_WFLOAT_AS_I128: i128 = -1_000_000; // 1e6 instead of  1e18
pub const ONE_WFLOAT_AS_I128: i128 = 1_000_000; // 1e6 instead of  1e18
pub const TWO_WFLOAT_AS_I128: i128 = 2_000_000; // 1e6 instead of  1e18
pub const HALF_WFLOAT_AS_I128: i128 = 500_000; // 0.5e6 instead of 0.5e18
pub const DECIMAL_WFLOAT_AS_I128: i128 = 100_000; // 0.1e6 instead of

pub const ZERO_WFLOAT : WFloat = WFloat { value: 0 };
pub const NEG_WFLOAT : WFloat = WFloat { value: NEG_WFLOAT_AS_I128 };
pub const ONE_WFLOAT : WFloat = WFloat { value: ONE_WFLOAT_AS_I128 };
pub const TWO_WFLOAT : WFloat = WFloat { value: TWO_WFLOAT_AS_I128 };
pub const HALF_WFLOAT : WFloat = WFloat { value : HALF_WFLOAT_AS_I128 };
pub const DECIMAL_WFLOAT : WFloat = WFloat { value : DECIMAL_WFLOAT_AS_I128 };

// not optimized, for debug purpose
fn lfill(string: ByteArray, n_digits: usize, character: ByteArray) -> ByteArray {
    if string.len() >= n_digits {
        string
    } else {
        lfill(character.clone() + string, n_digits, character)
    }
}

pub fn felt_wfloat_to_string(value: felt252, n_digits: usize) -> ByteArray {
    wfloat_to_string(felt_to_i128(@value), n_digits)
}

// not optimized, for debug purpose
pub fn wfloat_to_string(value: i128, n_digits: usize) -> ByteArray {
    let uvalue = value.as_unsigned();
    let sign: ByteArray = if value.is_positive() {
        ""
    } else {
        "-"
    };

    let integer_part = uvalue / pow(10, 6);
    let decimal_part = uvalue - (integer_part * pow(10, 6));
    let decimal_part_reduced = decimal_part / pow(10, 6 - n_digits.into());
    let decimal_part_as_string = format!("{}", decimal_part_reduced);

    format!("{}{}.{}", sign, integer_part, lfill(decimal_part_as_string, n_digits, "0"))
}

pub impl WFloatDisplay of Display<WFloat> {
    fn fmt(self: @WFloat, ref f: Formatter) -> Result<(), Error> {
        // let sign : ByteArray = if self.value.is_positive() { "" } else { "-" };
        // let positive : u128 = self.value.as_unsigned();
        // let units = positive / ONE_WFLOAT_AS_I128.as_unsigned();
        // let decimals = positive - (units * ONE_WFLOAT_AS_I128.as_unsigned());
        // write!(f, "{}{}.{}", sign, units, decimals)

        let result = wfloat_to_string(*self.value, 3);
        write!(f, "{result}")
    }
}

pub impl WFloatAdd of Add<WFloat> {
    #[inline]
    fn add(lhs: WFloat, rhs: WFloat) -> WFloat {
        WFloat { value: lhs.value + rhs.value }
    }
}

pub impl WFloatSub of Sub<WFloat> {
    #[inline]
    fn sub(lhs: WFloat, rhs: WFloat) -> WFloat {
        WFloat { value: lhs.value - rhs.value }
    }
}


pub impl WFloatMul of Mul<WFloat> {
    #[inline]
    fn mul(lhs: WFloat, rhs: WFloat) -> WFloat {
        WFloat { value: (lhs.value * rhs.value + HALF_WFLOAT_AS_I128) / ONE_WFLOAT_AS_I128 }
    }
}

pub impl WFloatDiv of Div<WFloat> {
    #[inline]
    fn div(lhs: WFloat, rhs: WFloat) -> WFloat {
        WFloat { value: (lhs.value * ONE_WFLOAT_AS_I128 + (rhs.value / 2)) / rhs.value }
    }
}

pub impl WFloatNeutral of NeutralElement<WFloat> {
    #[inline]
    fn neutral_element() -> WFloat {
        WFloatBasics::from_raw_i128(ONE_WFLOAT_AS_I128)
    }
}

pub impl WFloatInvertible of Invertible<WFloat> {
    #[inline]
    fn inv(self: @WFloat) -> WFloat {
        WFloatNeutral::neutral_element() / self.clone()
    }
}

pub impl WFloatOrder of PartialOrd<WFloat> {
    fn le(lhs: WFloat, rhs: WFloat) -> bool {
        lhs.value <= rhs.value
    }
    fn ge(lhs: WFloat, rhs: WFloat) -> bool {
        lhs.value >= rhs.value
    }
    fn lt(lhs: WFloat, rhs: WFloat) -> bool {
        lhs.value < rhs.value
    }
    fn gt(lhs: WFloat, rhs: WFloat) -> bool {
        lhs.value > rhs.value
    }
}

// TODO:
// pub impl WFloatRem of Rem<WFloat> {
//     fn rem()
// }

pub impl WFloatSignedBasics of ISignedBasics<WFloat> {
    #[inline]
    fn is_positive(self: @WFloat) -> bool {
        (self).value.is_positive()
    }
    #[inline]
    fn abs(self: @WFloat) -> WFloat {
        WFloat { value: (self).value.abs() }
    }

    #[inline]
    fn as_unsigned(self: @WFloat) -> u128 {
        (self).value.as_unsigned()
    }
    #[inline]
    fn as_felt(self: @WFloat) -> felt252 {
        (self).value.as_felt()
    }
    #[inline]
    fn as_unsigned_felt(self: @WFloat) -> felt252 {
        (self).value.as_unsigned_felt()
    }
}

#[generate_trait]
pub impl WFloatBasics of IWFloatBasics {
    #[inline]
    fn from_raw_felt(value: felt252) -> WFloat {
        WFloat { value: value.try_into().unwrap() }
    }

    #[inline]
    fn from_raw_unsigned(value: u128) -> WFloat {
        WFloat { value: value.try_into().unwrap() }
    }

    #[inline]
    fn from_raw_i128(value: i128) -> WFloat {
        WFloat { value: value }
    }

    #[inline]
    fn from_i128(value: i128) -> WFloat {
        WFloat { value: value * ONE_WFLOAT_AS_I128 }
    }

    #[inline]
    fn from_u128(value: u128) -> WFloat {
        WFloat { value: unsigned_to_signed(@value) * ONE_WFLOAT_AS_I128 }
    }


    fn from_pair(units: i128, decimals: u128, digits: usize) -> WFloat {
        let compensation = WFLOAT_POW - digits;

        let x: u128 = decimals * pow(10_u128, compensation.into());
        WFloat { value: (units * ONE_WFLOAT_AS_I128) + unsigned_to_signed(@x) }
    }


    #[inline]
    fn soft_floor(self: @WFloat, ndigits: usize) -> WFloat {
        let base = pow(10_i128, WFLOAT_POW - ndigits);
        WFloat { value: (*self.value / base) * base }
    }

    #[inline]
    fn floor(self: @WFloat) -> WFloat {
        self.soft_floor(0)
    }


    #[inline]
    fn to_raw_i128(self: @WFloat) -> i128 {
        *self.value
    }

    #[inline]
    fn to_floor_i128(self: @WFloat) -> i128 {
        (*self.value) / pow(10_i128, WFLOAT_POW)
    }

    #[inline]
    fn pow(self: @WFloat, exp: usize) -> WFloat {
        WFloat { value: pow(*self.value, exp) }
    }

    #[inline]
    fn pow_monoid(self: @WFloat, exp: i128) -> WFloat {
        pow_group(self.clone(), exp)
    }
}
