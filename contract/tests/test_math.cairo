use celestial_zkml::math;
use celestial_zkml::math::signed::{
    I128SignedBasics, unsigned_to_signed, felt_to_i128, I128Div, I128Display,
};
use celestial_zkml::math::wfloat::{
    WFloat, WFloatBasics,
    ZERO_WFLOAT, ONE_WFLOAT, NEG_WFLOAT, HALF_WFLOAT, DECIMAL_WFLOAT, 
};

// ----------------------------------------------------------

fn sep() -> () {
    println!("-----------------------------");
}

#[test]
fn float_works() -> () {
    // sep();
    // println!("FLOAT VERIFICATIONS !");

    // sep();
    // println!("generate");
    // let u = WFloatBasics::from_pair(10, 023, 3);
    // println!("this: {u}");

    // sep();
    let x = WFloatBasics::from_pair(20, 0, 0);
    let y = WFloatBasics::from_pair(0, 5, 1);
    let z = (x * y).pow_monoid(-2_i128);
    assert!(z == WFloatBasics::from_pair(0, 01, 2));
    // println!("z = {z}");
    
    // let w = z + WFloatBasics::from_pair(0, 25, 2);
    // println!("w = {w}");
    // sep();
}
