use astral_zkml::math::ml::ISequentialBasics;
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

use astral_zkml::math::ml::{
    Sequential, SequentialBasics,
    ActivationFunction, DEFAULT_SGD,
    DenseLayer, DenseLayerBasics
};

// ----------------------------------------------------------

#[test]
fn build_neural_network() {
    let layers : Span<DenseLayer> = array![
        DenseLayerBasics::init( 
            input_shape: Option::Some(3),
            output_shape: 4,
            activation_function: ActivationFunction::ReLU,
            seed: Option::None
         )
    ].span();
    
    let mut model = SequentialBasics::init(
        layers, DEFAULT_SGD, Option::None
    );

    
    let X = MatrixBasics::from_i128(@array![
    array![1, 0, 0].span(),
    array![0, 3, 2].span(),
    array![4, 2, 1].span(),
    array![5, 2, 1].span(),
    array![1, 2, 5].span(),
    ].span());
    
    sep();
    println!("X = \n{X}");
    
    let y = model.forward(@X);
    
    sep();
    println!("y = \n{y}");

    let someY = MatrixBasics::from_i128(@array![
        // array![3, 5, 2, 4 ].span(),
        // array![3, 9, 1, 2 ].span(),
        // array![5, 9, 1, 2 ].span(),
        // array![5, 9, 1, 2 ].span(),
        // array![5, 5, 2, 4 ].span(),
        array![1, 3, 5, 1].span(),
        array![1, 3, 5, 1].span(),
        array![1, 3, 5, 1].span(),
        array![1, 3, 5, 1].span(),
        array![1, 3, 5, 1].span()
    ].span());

    model.train(@X, @someY, 10, Option::None);
    println!("z = \n{}", model.forward(@X));
}