use astral_zkml::math::wfloat::{
    WFloat, WFloatBasics,
    ZERO_WFLOAT, ONE_WFLOAT, NEG_WFLOAT, HALF_WFLOAT, DECIMAL_WFLOAT, 
};

use astral_zkml::math::vector::{
    Vector, VectorBasics
};
use astral_zkml::math::matrix::{
    Matrix, MatrixBasics
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

pub struct Sequential {

}