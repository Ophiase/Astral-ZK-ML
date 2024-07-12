use super::wfloat::{
    WFloat, WFloatBasics, WFloatSignedBasics
};

// -------------------------------------------------

#[derive(Drop, Destruct, Copy)]
pub trait IComponentLambda<T, U, V> {
    fn apply(self: @T, input : @U) -> V;
}

// -------------------------------------------------

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

// -------------------------------------------------

pub impl LRawFeltAsWFloat of IComponentLambda<RawFeltAsWFloat,felt252, WFloat> {
    fn apply(self: @RawFeltAsWFloat, input : @felt252) -> WFloat {
        WFloatBasics::from_raw_felt(*input)
    }
}

pub impl LRawI128AsWFloat of IComponentLambda<RawI128AsWFloat,i128, WFloat> {
    fn apply(self: @RawI128AsWFloat, input : @i128) -> WFloat {
        WFloatBasics::from_raw_i128(*input)
    }
}

pub impl LI128AsWFloat of IComponentLambda<I128AsWFloat, i128, WFloat> {
    fn apply(self: @I128AsWFloat, input : @i128) -> WFloat {
        WFloatBasics::from_i128(*input)
    }
}

pub impl LU128AsWFloat of IComponentLambda<U128AsWFloat, u128, WFloat> {
    fn apply(self: @U128AsWFloat, input : @u128) -> WFloat {
        WFloatBasics::from_u128(*input)
    }
}

pub impl LWFloatAsRawFelt of IComponentLambda<WFloatAsRawFelt, WFloat, felt252> {
    fn apply(self: @WFloatAsRawFelt, input : @WFloat) -> felt252 {
        input.as_felt()
    }
}

pub impl LWFloatMultiplier of IComponentLambda<WFloatMultiplier, WFloat, WFloat> {
    fn apply(self: @WFloatMultiplier, input : @WFloat) -> WFloat {
        *self.factor * *input
    }
}