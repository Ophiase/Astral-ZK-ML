use core::option::OptionTrait;
use astral_zkml::math::algebra::Invertible;
use astral_zkml::math::vector::IVectorBasics;
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
use super::component_lambda::{
    Exponential, ReLU, ReLUDerivative
};

// MACHINE LEARNING
// -------------------------------------------------

#[derive(Copy, Drop, Hash, Serde, starknet::Store)]
pub enum LossFunctionType {
    MSE,
    CrossEntropy
}

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

pub fn relu(x: @WFloat) -> WFloat {
    if *x > ZERO_WFLOAT {
        *x
    } else {
        ZERO_WFLOAT
    }
}

pub fn relu_derivative(x: @WFloat) -> WFloat {
    if *x > ZERO_WFLOAT {
        ONE_WFLOAT
    } else {
        ZERO_WFLOAT
    }
}

pub fn softmax(x: @Vector) -> Vector {
    let denormalized = x.apply(Exponential {});
    let normalizer = denormalized.sum();
    denormalized.divide_by(normalizer)
}

// TODO:
// pub fn softmax_derivative(x: &Vector) -> Vector {
    // Softmax is complex to implements in general case
    // When the Loss function is Cross Entropy, it's easy
    // TODO: add CrossEntropy Choice
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

#[derive(Copy, Drop)]
trait ILayer<T> {
    fn build(ref self : T, input_shape: usize) -> ();
    fn forward(ref self : T, X: Matrix) -> Matrix;
    fn backward(ref self : T, dY: Matrix, learning_rate: WFloat) -> Matrix;
    fn num_params(ref self : @T) -> usize;
}

#[derive(Copy, Drop)]
struct DenseLayer {
    built : bool,

    input_shape: usize,
    output_shape: usize,
    activationFunction: ActivationFunction,
    
    weights: Matrix,
    biaises: Vector,
}

struct SGD {
    learning_rate: WFloat,
    loss: LossFunctionType
}

pub struct Sequential {
    layers : Span<DenseLayer>,
    optimizer: SGD,
    // history: Array<WFloat>
}

// -------------------------------------------------

#[generate_trait]
impl DenseLayerBasics of IDenseLayerBasics {
    fn init(
        input_shape: Option<usize>, 
        output_shape: usize,
        activation_function : ActivationFunction
    ) -> DenseLayer {
        let mut layer = DenseLayer {
            built : false,

            input_shape: 0,
            output_shape: output_shape,
            activationFunction: activation_function,
        
            weights: MatrixBasics::zeros((0,0)),
            biaises: VectorBasics::zeros(0),
        };

        if input_shape.is_none() {
            layer.build(input_shape.unwrap())
        }

        layer
    }
}

impl DenseLayerImpl of ILayer<DenseLayer> {
    // TODO
    fn build(ref self : DenseLayer, input_shape: usize) -> () {

    }

    // TODO:
    fn forward(ref self : DenseLayer, X: Matrix) -> Matrix {
        X
    }

    // TODO:
    fn backward(ref self : DenseLayer, dY: Matrix, learning_rate: WFloat) -> Matrix {
        dY
    }
    
    
    fn num_params(ref self : @DenseLayer) -> usize {
        1_usize + *self.output_shape + (*self.input_shape * *self.output_shape) 
    }
}