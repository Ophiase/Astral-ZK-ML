use super::wfloat::{WFloat, WFloatBasics, WFloatSignedBasics};
use super::function::{exp};
use super::ml::{
    relu, relu_derivative,
    sigmoid, sigmoid_derivative,
    ActivationFunction
};

// -------------------------------------------------

#[derive(Drop, Destruct, Copy)]
pub trait IComponentLambda<T, U, V> {
    fn apply(self: @T, input: @U) -> V;
}

// -------------------------------------------------

#[derive(Drop, Copy)]
pub struct Identity {}

#[derive(Drop, Copy)]
pub struct RawFeltAsWFloat {}
#[derive(Drop, Copy)]
pub struct RawI128AsWFloat {}
#[derive(Drop, Copy)]
pub struct I128AsWFloat {}
#[derive(Drop, Copy)]
pub struct U128AsWFloat {}
#[derive(Drop, Copy)]
pub struct WFloatAsRawFelt {}
#[derive(Drop, Copy)]
pub struct WFloatMultiplier {
    pub factor: WFloat
}
#[derive(Drop, Copy)]
pub struct WFloatDivider {
    pub factor: WFloat
}

#[derive(Drop, Copy)]
pub struct Exponential {}

#[derive(Drop, Copy)]
pub struct ReLU {}
#[derive(Drop, Copy)]
pub struct ReLUDerivative {}
#[derive(Drop, Copy)]
pub struct Sigmoid {}
#[derive(Drop, Copy)]
pub struct SigmoidDerivative {}

#[derive(Drop, Copy)]
pub struct LambdaActivation { 
    pub activation_function: ActivationFunction
}
#[derive(Drop, Copy)]
pub struct LambdaActivationDerivative {
    pub activation_function: ActivationFunction
}

// -------------------------------------------------

pub impl LIdentity of IComponentLambda<Identity, WFloat, WFloat> {
    fn apply(self: @RawFeltAsWFloat, input: @WFloat) -> WFloat {
        *input
    }
}

pub impl LRawFeltAsWFloat of IComponentLambda<RawFeltAsWFloat, felt252, WFloat> {
    fn apply(self: @RawFeltAsWFloat, input: @felt252) -> WFloat {
        WFloatBasics::from_raw_felt(*input)
    }
}

pub impl LRawI128AsWFloat of IComponentLambda<RawI128AsWFloat, i128, WFloat> {
    fn apply(self: @RawI128AsWFloat, input: @i128) -> WFloat {
        WFloatBasics::from_raw_i128(*input)
    }
}

pub impl LI128AsWFloat of IComponentLambda<I128AsWFloat, i128, WFloat> {
    fn apply(self: @I128AsWFloat, input: @i128) -> WFloat {
        WFloatBasics::from_i128(*input)
    }
}

pub impl LU128AsWFloat of IComponentLambda<U128AsWFloat, u128, WFloat> {
    fn apply(self: @U128AsWFloat, input: @u128) -> WFloat {
        WFloatBasics::from_u128(*input)
    }
}

pub impl LWFloatAsRawFelt of IComponentLambda<WFloatAsRawFelt, WFloat, felt252> {
    fn apply(self: @WFloatAsRawFelt, input: @WFloat) -> felt252 {
        input.as_felt()
    }
}

pub impl LWFloatMultiplier of IComponentLambda<WFloatMultiplier, WFloat, WFloat> {
    fn apply(self: @WFloatMultiplier, input: @WFloat) -> WFloat {
        *self.factor * *input
    }
}

pub impl LWFloatDivider of IComponentLambda<WFloatDivider, WFloat, WFloat> {
    fn apply(self: @WFloatDivider, input: @WFloat) -> WFloat {
        *input / *self.factor
    }
}


pub impl LExponential of IComponentLambda<Exponential, WFloat, WFloat> {
    fn apply(self: @Exponential, input: @WFloat) -> WFloat {
        exp(input)
    }
}

pub impl LReLU of IComponentLambda<ReLU, WFloat, WFloat> {
    fn apply(self: @ReLU, input: @WFloat) -> WFloat {
        relu(input)
    }
}

pub impl LReLUDerivative of IComponentLambda<ReLUDerivative, WFloat, WFloat> {
    fn apply(self: @ReLUDerivative, input: @WFloat) -> WFloat {
        relu_derivative(input)
    }
}

pub impl LSigmoid of IComponentLambda<Sigmoid, WFloat, WFloat> {
    fn apply(self: @Sigmoid, input: @WFloat) -> WFloat {
        sigmoid(input)
    }
}

pub impl LSigmoidActivationDerivative of IComponentLambda<SigmoidDerivative, WFloat, WFloat> {
    fn apply(self: @SigmoidDerivative, input: @WFloat) -> WFloat {
        sigmoid_derivative(input)
    }
}

pub impl LLambdaActivation of IComponentLambda<LambdaActivation, WFloat, WFloat> {
    fn apply(self: @LambdaActivation, input: @WFloat) -> WFloat {
        relu(input)
        // match self.activation_function {
        //     ActivationFunction::ReLU => relu(input),
        //     ActivationFunction::Sigmoid => sigmoid(input),
        //     ActivationFunction::SoftMax => panic!("Not Implemented")
        // }
    }
}

pub impl LLambdaActivationDerivative of IComponentLambda<LambdaActivationDerivative, WFloat, WFloat> {
    fn apply(self: @LambdaActivationDerivative, input: @WFloat) -> WFloat {
        relu_derivative(input)

        // HIGH COST
        // match self.activation_function {
        //     ActivationFunction::ReLU => relu_derivative(input),
        //     ActivationFunction::Sigmoid => sigmoid_derivative(input),
        //     ActivationFunction::SoftMax => panic!("Not Implemented")
        // }
    }
}
