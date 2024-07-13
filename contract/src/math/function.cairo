use super::wfloat::{
    WFloat, WFloatBasics, ZERO_WFLOAT, ONE_WFLOAT, TWO_WFLOAT, NEG_WFLOAT, HALF_WFLOAT,
    DECIMAL_WFLOAT,
};

// -------------------------------------------------
// BASIC FUNCTIONS
// -------------------------------------------------

const MAX_SQRT_ITERATIONS: usize = 50;
pub fn sqrt(value: WFloat) -> WFloat {
    if (value == ZERO_WFLOAT) {
        return ZERO_WFLOAT;
    }

    let mut g = value / TWO_WFLOAT;
    let mut g2 = g + ONE_WFLOAT;

    let mut i = 0;
    loop {
        if g == g2 || i == MAX_SQRT_ITERATIONS {
            break (g);
        }

        let n = value / g;
        g2 = g;
        g = (g + n) / TWO_WFLOAT;

        i += 1;
    }
}

#[inline]
pub fn max(lhs: WFloat, rhs: WFloat) -> WFloat {
    if lhs > rhs {
        lhs
    } else {
        rhs
    }
}

#[inline]
pub fn min(lhs: WFloat, rhs: WFloat) -> WFloat {
    if lhs < rhs {
        lhs
    } else {
        rhs
    }
}

// TODO
pub fn exp(x: @WFloat) -> WFloat {
    let mut sum = ONE_WFLOAT;
    let mut term = ONE_WFLOAT;
    let mut n = ONE_WFLOAT;
    let mut i = 0;
    loop {
        if i == 100 {
            break ();
        }
        term = term * (*x / n);
        sum = sum + term;
        n = n + ONE_WFLOAT;
        i += 1;
    };
    sum
}
