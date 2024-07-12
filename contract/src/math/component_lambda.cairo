// TODO

// For component wise operations

use super::wfloat::{
    WFloat, WFloatBasics, WFloatSignedBasics
};

// -------------------------------------------------

#[derive(Drop, Destruct, Copy)]
pub trait IComponentLambda<T, U, V> {
    fn apply(self: @T, input : @U) -> V;
}
