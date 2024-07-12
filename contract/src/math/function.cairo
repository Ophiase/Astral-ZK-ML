use super::wfloat::{
    WFloat, WFloatBasics,
    ZERO_WFLOAT, ONE_WFLOAT, TWO_WFLOAT, NEG_WFLOAT, HALF_WFLOAT, DECIMAL_WFLOAT, 
};

// -------------------------------------------------
// BASIC FUNCTIONS
// -------------------------------------------------

const MAX_SQRT_ITERATIONS : usize = 50;
pub fn sqrt(value : WFloat) -> WFloat {
    if (value == ZERO_WFLOAT) {
        return ZERO_WFLOAT;
    }

    let mut g = value / TWO_WFLOAT;
    let mut g2 = g + ONE_WFLOAT;

    let mut i = 0;
    loop {
        if g == g2 || i == MAX_SQRT_ITERATIONS {
            break(g);
        }

        let n = value / g;
        g2 = g;
        g = (g + n) / TWO_WFLOAT;

        i += 1;
    }
}