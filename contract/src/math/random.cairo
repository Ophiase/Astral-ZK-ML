use super::wfloat::{
    WFloat, WFloatBasics, ONE_WFLOAT_AS_I128, ONE_WFLOAT, TWO_WFLOAT
};

// PSEUDO RANDOM
// -------------------------------------------------

pub const default_seed : u64 = 95732;

const A : u64 = 1664525;
const C : u64 = 1013904223;
const M : u64 = 4294967296; // 2^32
const M_FLOAT : WFloat = WFloat{ value: ONE_WFLOAT_AS_I128 * 4294967296 };

pub fn lcg_rand(seed : u64) -> u64 {
    (A * seed + C) % M
}

pub fn normalize_lgn_rand(lgc_rand_result : u64) -> WFloat {
    let lgc_float = WFloatBasics::from_u64(lgc_rand_result);
    lgc_float / M_FLOAT
}

pub fn normalize_lgn_rand_11(lgc_rand_result : u64) -> WFloat {
    let lgc_float = WFloatBasics::from_u64(lgc_rand_result);
    (TWO_WFLOAT *  lgc_float / M_FLOAT) - ONE_WFLOAT
}