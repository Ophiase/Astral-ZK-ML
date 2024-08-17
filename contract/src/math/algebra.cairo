use super::signed::{I128SignedBasics};

// Implementations based on alexandria implementation : 
// https://github.com/keep-starknet-strange/alexandria/blob/main/packages/math/src/lib.cairo

// For Multiplicative group (into a Ring)
// TODO: don't use it, its a bad idea
pub trait NeutralElement<T> {
    fn neutral_element() -> T;
}

// For Multiplicative group (into a Ring)
// TODO: don't use it, its a bad idea
pub trait Invertible<T> {
    fn inv(self: @T) -> T;
}

// Based on Alexandria pow
//
// Raise a number to a power.
// O(log n) time complexity.
// * `base` - The number to raise.
// * `exp` - The exponent.
// # Returns
// * `T` - The result of base raised to the power of exp.
pub fn pow<T, +Sub<T>, +Mul<T>, +PartialEq<T>, +Into<u8, T>, +Drop<T>, +Copy<T>>(
    base: T, exp: usize
) -> T {
    if exp == 0_usize {
        1_u8.into()
    } else if exp == 1_usize {
        base
    } else if exp % 2_usize == 0_usize {
        pow(base * base, exp / 2_usize)
    } else {
        base * pow(base * base, exp / 2_usize)
    }
}

pub fn pow_monoid<T, +Sub<T>, +Mul<T>, +PartialEq<T>, +Drop<T>, +Copy<T>>(
    base: T, exp: usize, unit: @T
) -> T {
    if exp == 0_usize {
        *unit
    } else if exp == 1_usize {
        base
    } else if exp % 2_usize == 0_usize {
        pow_monoid(base * base, exp / 2_usize, unit)
    } else {
        base * pow_monoid(base * base, exp / 2_usize, unit)
    }
}

pub fn pow_group<
    T,
    +Sub<T>,
    +Mul<T>,
    +Div<T>,
    +PartialEq<T>,
    +Drop<T>,
    +Copy<T>,
    +NeutralElement<T>,
    +Invertible<T>
>(
    base: T, exp: i128
) -> T {
    if exp == 0_i128 {
        NeutralElement::neutral_element()
    } else if exp == 1_i128 {
        base
    } else if exp < 0 {
        Invertible::inv(@pow_group(base, -exp))
    } else if exp.as_unsigned() % 2_u128 == 0_u128 {
        pow_group(base * base, exp / 2_i128)
    } else {
        base * pow_group(base * base, exp / 2_i128)
    }
}
