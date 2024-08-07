use astral_zkml::math;
use astral_zkml::math::signed::{
    I128SignedBasics, unsigned_to_signed, felt_to_i128, I128Div, I128Display,
};
use astral_zkml::math::wfloat::{
    WFloat, WFloatBasics, ZERO_WFLOAT, ONE_WFLOAT, NEG_WFLOAT, HALF_WFLOAT, DECIMAL_WFLOAT,
};

use astral_zkml::math::vector::{Vector, VectorBasics};
use astral_zkml::math::matrix::{Matrix, MatrixBasics};

use astral_zkml::math::function::{exp};
use astral_zkml::utils::{sep};

// ----------------------------------------------------------

#[ignore]
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

#[ignore]
#[test]
fn vector_works() -> () {
    let v1 = VectorBasics::from_i128(@array![10_i128, 5, 6].span());
    let v2 = VectorBasics::from_i128(@array![10_i128, 20, 30].span());
    let v3 = v1 + v2;

    // println!("{v1} + {v2} = {v3}");
    assert!(v3 == VectorBasics::from_i128(@array![20_i128, 25, 36].span()), "v3 wrong value");

    let v4 = VectorBasics::from_i128(@array![1_i128, 3_i128, 10_i128].span());
    let v5 = v3 * v4;

    // println!("{v5}");
    assert!(v5 == VectorBasics::from_i128(@array![20_i128, 75, 360].span()), "v5 wrong value");

    let v6 = v5.scale(WFloatBasics::from_pair(10, 0, 0));
    assert!(v6 == VectorBasics::from_i128(@array![200_i128, 750, 3600].span()), "v6 wrong value");
// println!("{}",
//     VectorBasics::ones(2).norm()
// );

// println!("{}",
//     VectorBasics::from_i128(@array![2_i128, 3, 0].span()).norm()
// );
}

#[ignore]
#[test]
fn matrix_works() -> () {
    let m1 = MatrixBasics::identity((3, 3));
    // println!("{m1}");
    // sep();

    let m2 = MatrixBasics::from_i128(
        @array![
            array![1_i128, 0, 0].span(), array![1_i128, 1, 0].span(), array![1_i128, 0, 3].span(),
        ]
            .span()
    );
    // println!("{m2}");
    // sep();

    let m3 = MatrixBasics::from_i128(
        @array![
            array![1_i128, 0, 0].span(), array![0_i128, 0, 0].span(), array![1_i128, 0, 2].span(),
        ]
            .span()
    );
    // println!("{m3}");

    // sep();
    // println!("{} +\n {} =\n {}", m1, m2, m1 + m2);

    // sep();
    // println!("{} x\n {} =\n {}", m1, m2, m1 * m2);

    // sep();
    // println!("{} x\n {} =\n {}", m2, m3, m2 * m3);

    // let m4 = MatrixBasics::from_i128(@array![
    //     array![1_i128, 2].span(),
    //     array![3_i128, 4].span()
    // ].span());

    // let m5 = MatrixBasics::from_i128(@array![
    //     array![1_i128, 2].span(),
    //     array![3_i128, 4].span(),
    //     array![2_i128, 1].span()
    // ].span());

    // sep();
    // println!("{m4}");
    // println!("{m5}");
    // println!("{}", m5.dot(@m4));

    // let m6 = MatrixBasics::from_i128(@array![
    //     array![1_i128, 2].span(),
    //     array![3_i128, 4].span(),
    //     array![1_i128, 2].span()
    // ].span());

    // let m7 = MatrixBasics::from_i128(@array![
    //     array![1_i128, 2, 1].span(),
    //     array![3_i128, 4, 1].span(),
    // ].span());

    // sep();
    // println!("{m6}");
    // println!("{m7}");
    // println!("{}", m7.dot(@m6));

    let _ = m1 + m2 + m3;
}

#[ignore]
#[test]
fn check_exp_function() -> () {
    println!("{}", exp(@WFloatBasics::from_i128(1)));
    println!("{}", exp(@WFloatBasics::from_i128(2)));
    println!("{}", exp(@WFloatBasics::from_i128(3)));
}

#[ignore]
#[test]
fn check_activation_function() -> () {}
