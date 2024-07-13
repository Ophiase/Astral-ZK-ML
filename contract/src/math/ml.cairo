use astral_zkml::math::matrix::IMatrixBasics;
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
use super::random::{
    default_seed, lcg_rand, normalize_lgn_rand, normalize_lgn_rand_11
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
    fn build(ref self : T, input_shape: usize, seed: Option<u64>) -> ();
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
    
    cache_input: Matrix,
    cache_z: Matrix,
    cache_output: Matrix,

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
        activation_function : ActivationFunction,
        seed: Option<u64>
    ) -> DenseLayer {
        let mut layer = DenseLayer {
            built : false,

            input_shape: 0,
            output_shape: output_shape,
            activationFunction: activation_function,

            cache_input: MatrixBasics::zeros((0,0)),
            cache_z: MatrixBasics::zeros((0,0)),
            cache_output: MatrixBasics::zeros((0,0)),
        
            weights: MatrixBasics::zeros((0,0)),
            biaises: VectorBasics::zeros(0),
        };

        if !input_shape.is_none() {
            layer.input_shape = input_shape.unwrap();
            if !seed.is_none() {
                layer.build(input_shape.unwrap(), seed)
            }
        }

        layer
    }

    fn _init_weights(ref self : DenseLayer, seed : u64) -> () {
        
    } 
    fn _init_biaises(ref self : DenseLayer, seed : u64) -> () {
        
    } 

}

impl DenseLayerImpl of ILayer<DenseLayer> {
    fn build(ref self : DenseLayer, input_shape: usize, seed : Option<u64>) -> () {
        let seed = match seed {
            Option::Some(x) => x,
            Option::None => default_seed
        };
        
        self.input_shape = input_shape;
        self._init_weights(seed + 29399);
        self._init_biaises(seed + 18839);
        self.built = true;
    }

    fn forward(ref self : DenseLayer, X: Matrix) -> Matrix {
        self.cache_input = X;
        self.cache_z = (X.dot(@self.weights)).row_wise_addition(@self.biaises);
        self.cache_output = self.cache_z.apply(
            match self.activationFunction {
                ActivationFunction::ReLU => ReLU {},
                // TODO: apply softmax row-wise 
                ActivationFunction::SoftMax => panic!("Not Implemented")
            }
        );

        X
    }

    fn backward(ref self : DenseLayer, dY: Matrix, learning_rate: WFloat) -> Matrix {
        let m = dY.dimX();
        let m_float = WFloatBasics::from_u64(m.into()); 
        let dZ = dY * self.cache_z.apply( 
            match self.activationFunction {
                ActivationFunction::ReLU => ReLUDerivative {},
                // TODO: apply softmax row-wise 
                ActivationFunction::SoftMax => panic!("Not Implemented")
            }
        );

        let dW = (self.cache_input.transpose()).dot(@dZ).divide_by(m_float);
        let dB = dZ.sum().divide_by(m_float);
        let dX = dZ.dot(@self.weights.transpose());

        self.weights = self.weights - dW.scale(learning_rate);
        self.biaises = self.biaises - dB.scale(learning_rate); 

        dX
    }
    
    fn num_params(ref self : @DenseLayer) -> usize {
        1_usize + *self.output_shape + (*self.input_shape * *self.output_shape) 
    }
}