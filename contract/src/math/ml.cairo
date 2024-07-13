use super::wfloat::{
    WFloat, WFloatBasics,
    ZERO_WFLOAT, ONE_WFLOAT, NEG_WFLOAT, HALF_WFLOAT, DECIMAL_WFLOAT, 
};

use super::vector::{
    Vector, VectorBasics
};
use super::matrix::{
    Matrix, MatrixBasics
};
use super::function::{
    exp
};

// -------------------------------------------------

#[derive(Copy, Drop, Hash, Serde, starknet::Store)]
pub enum LayerType {
    Dense,
    Flatten,
    Conv2D,
    MaxPool
}

#[derive(Copy, Drop, Hash, Serde, starknet::Store)]
pub enum ActivationFunction {
    ReLU,
    SoftMax
}

pub fn relu(x: WFloat) -> WFloat {
    if x > ZERO_WFLOAT {
        x
    } else {
        ZERO_WFLOAT
    }
}

pub fn relu_derivative(x: WFloat) -> WFloat {
    if x > ZERO_WFLOAT {
        ONE_WFLOAT
    } else {
        ZERO_WFLOAT
    }
}

// pub fn softmax(x: @Vector) -> Vector {
//     let mut exp_values = ArrayTrait::new();
//     let mut sum_exp = ZERO_WFLOAT;

    // let mut i = 0;
    // loop {
    //     if i ==  { break(); }
        
    //     i += 1;
    // };

    // for &value in x.iter() {

    //     let exp_value = exp(value);
    //     exp_values.push(exp_value);
    //     sum_exp = sum_exp + exp_value;
    // }
    
    // let mut softmax_values = ArrayTrait::new();
    // for &value in exp_values.iter() {
    //     softmax_values.push(value / sum_exp);
    // }
    
//     softmax_values
// }

// pub fn softmax_derivative(x: &Vector) -> Vector {
//     let softmax_values = softmax(x);
//     let mut derivative_values = Vector::with_capacity(x.len());
    
//     for i in 0..x.len() {
//         let s = softmax_values[i];
//         derivative_values.push(s * (ONE_WFLOAT - s));
//     }
    
//     derivative_values
// }


// -------------------------------------------------
// For Storage

#[derive(Copy, Drop, Hash, Serde, starknet::Store)]
pub enum SerializedLayerIndex {
    InputSize,
    OutputSize,

    // Type: LayerType,
    Biais: usize,
    WeightMatrix: (usize, usize),
    ActivationFunction: ActivationFunction
}

#[derive(Copy, Drop, Hash, Serde, starknet::Store)]
pub enum SerializedLayerContent {
    InputSize: usize,
    OutputSize: usize,

    Weight: felt252
}

// -------------------------------------------------

trait ILayer<T> {
    fn build(ref self : T, input_shape: usize) -> ();
    fn forward(ref self : T, X: Matrix) -> Matrix;
    fn backward(ref self : T, dY: Matrix, learning_rate: WFloat) -> Matrix;
    fn num_params(ref self : @T) -> usize;
}

struct DenseLayer {
    built : bool,

    input_shape: usize,
    output_shape: usize,
    activationFunction: ActivationFunction,
    
    forward_activation: Vector,
    forward_activation_derivative: Vector,

    weights: Matrix,
    weights_derivative: Matrix,

    biaises: Vector,
    biaises_derivative: Vector
}

struct SGD {
    learning_rate: WFloat
}

pub struct Sequential {
    layers : Span<DenseLayer>,
    optimizer: SGD,
    // history: Array<WFloat>
}

// -------------------------------------------------

// #[generate_trait]
// impl DenseLayerBasics of IDenseLayerBasics {
//     fn init(
//         input_shape: Option<usize>, 
//         output_shape: usize,
//         activation_function : ActivationFunction 
//     ) -> DenseLayer {

//     }
// }

// impl DenseLayerImpl of ILayer<DenseLayer> {
//     fn build(ref self : DenseLayer, input_shape: usize) -> ();
//     fn forward(ref self : DenseLayer, X: Matrix) -> Matrix;
//     fn backward(ref self : DenseLayer, dY: Matrix, learning_rate: WFloat) -> Matrix;
//     fn num_params(ref self : @DenseLayer) -> usize;
// }