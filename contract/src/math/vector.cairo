use core::array::SpanTrait;
use core::byte_array::ByteArrayTrait;
use core::clone::Clone;
use core::option::OptionTrait;
use core::traits::TryInto;
use core::fmt::{Display, Formatter, Error};

use super::signed::{
    ISignedBasics, I128SignedBasics, unsigned_to_signed, felt_to_i128, I128Div, I128Display,
};

use super::wfloat::{
    WFloat, WFloatBasics, ZERO_WFLOAT, ONE_WFLOAT, NEG_WFLOAT, HALF_WFLOAT, DECIMAL_WFLOAT,
};
use super::component_lambda::{
    IComponentLambda, RawFeltAsWFloat, RawI128AsWFloat, I128AsWFloat, U128AsWFloat, WFloatAsRawFelt,
    WFloatMultiplier, WFloatDivider
};
use super::function;
use super::function::{sqrt};

use super::algebra::{NeutralElement, Invertible, pow, pow_monoid};
use super::random::{lcg_rand, normalize_lgn_rand_11, normalize_lgn_rand};

// -------------------------------------------------
// VECTOR
// -------------------------------------------------

#[derive(PartialEq, Drop, Copy, Serde)] //, Hash, starknet::Store)]
pub struct Vector {
    pub content: Span<WFloat>
}

// -------------------------------------------------

fn vector_to_string(vector: @Vector) -> ByteArray {
    let content = vector.content;

    let mut result: ByteArray = "";
    let begin_line: ByteArray = "[";
    let end_line: ByteArray = "]";

    result.append(@begin_line);
    let mut i = 0;
    loop {
        if i == (*content).len() {
            break ();
        }

        let e = *(*content).at(i);
        result.append(@format!("{e}, "));

        i += 1;
    };
    result.append(@end_line);

    result
}

pub impl VectorDisplay of Display<Vector> {
    fn fmt(self: @Vector, ref f: Formatter) -> Result<(), Error> {
        write!(f, "{}", vector_to_string(self))
    }
}

// ARITHMETIC
// -------------------------------------------------

pub impl VectorAdd of Add<Vector> {
    fn add(lhs: Vector, rhs: Vector) -> Vector {
        let mut result = ArrayTrait::new();

        let left = lhs.content;
        let right = rhs.content;

        assert!(left.len() == right.len(), "add error: different size");

        let length = left.len();

        let mut i = 0;
        loop {
            if i == length {
                break ();
            }

            let component = *left.at(i) + *right.at(i);
            result.append(component);

            i += 1;
        };

        Vector { content: result.span() }
    }
}

pub impl VectorSub of Sub<Vector> {
    fn sub(lhs: Vector, rhs: Vector) -> Vector {
        let mut result = ArrayTrait::new();

        let left = lhs.content;
        let right = rhs.content;

        assert!(left.len() == right.len(), "add error: different size");

        let length = left.len();

        let mut i = 0;
        loop {
            if i == length {
                break ();
            }

            let component = *left.at(i) - *right.at(i);
            result.append(component);

            i += 1;
        };

        Vector { content: result.span() }
    }
}

// Compute the Dot Product
pub impl VectorMul of Mul<Vector> {
    fn mul(lhs: Vector, rhs: Vector) -> Vector {
        let mut result = ArrayTrait::new();

        let left = lhs.content;
        let right = rhs.content;

        assert!(left.len() == right.len(), "add error: different size");

        let length = left.len();

        let mut i = 0;
        loop {
            if i == length {
                break ();
            }

            let component = *left.at(i) * *right.at(i);
            result.append(component);

            i += 1;
        };

        Vector { content: result.span() }
    }
}

pub impl VectorDiv of Div<Vector> {
    fn div(lhs: Vector, rhs: Vector) -> Vector {
        let mut result = ArrayTrait::new();

        let left = lhs.content;
        let right = rhs.content;

        assert!(left.len() == right.len(), "add error: different size");

        let length = left.len();

        let mut i = 0;
        loop {
            if i == length {
                break ();
            }

            let component = *left.at(i) * *right.at(i);
            result.append(component);

            i += 1;
        };

        Vector { content: result.span() }
    }
}

// TODO:
// pub impl MatrixInvertible of Invertible<Matrix> {
//     fn inv(self: @Matrix) -> Matrix {
//         WFloatNeutral::neutral_element() / self.clone()
//     }
// }

// -------------------------------------------------

#[generate_trait]
pub impl VectorBasics of IVectorBasics {
    #[inline]
    fn len(self: @Vector) -> usize {
        (*self).content.len()
    }

    #[inline]
    fn at(self: @Vector, i: usize) -> WFloat {
        *(*self).content.at(i)
    }

    // Constructors
    // -------------------------------------------------

    fn fill(size: usize, value: @WFloat) -> Vector {
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == size {
                break ();
            }
            result.append(*value);
            i += 1;
        };

        Vector { content: result.span() }
    }

    #[inline]
    fn ones(size: usize) -> Vector {
        VectorBasics::fill(size, @ONE_WFLOAT)
    }

    #[inline]
    fn zeros(size: usize) -> Vector {
        VectorBasics::fill(size, @ZERO_WFLOAT)
    }

    // build a vector with a 1 at ith position : (0, ... 0, 1, 0, ... 0)
    fn one_one(size: usize, position: usize) -> Vector {
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == size {
                break ();
            } else if i == position {
                result.append(ONE_WFLOAT);
            } else {
                result.append(ZERO_WFLOAT);
            }
            i += 1;
        };

        Vector { content: result.span() }
    }

    fn apply<T, +Drop<T>, +IComponentLambda<T, WFloat, WFloat>>(
        self: @Vector, lambda: T
    ) -> Vector {
        let mut result = ArrayTrait::new();
        let content = *(self.content);

        let mut i = 0;
        loop {
            if i == self.len() {
                break ();
            }

            let component = lambda.apply(content.at(i));
            result.append(component);

            i += 1;
        };

        Vector { content: result.span() }
    }

    fn from_wfloat(content: @Span<WFloat>) -> Vector {
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == (*content).len() {
                break ();
            }

            let component = *(*content).at(i);
            result.append(component);

            i += 1;
        };
        Vector { content: result.span() }
    }

    fn from_lambda<T, U, +Drop<T>, +Destruct<T>, +IComponentLambda<T, U, WFloat>>(
        content: @Span<U>, lambda: T
    ) -> Vector {
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == (*content).len() {
                break ();
            }

            let component = lambda.apply((*content).at(i));
            result.append(component);

            i += 1;
        };
        Vector { content: result.span() }
    }

    fn apply_extern<T, U, +Drop<U>, +Drop<T>, +Destruct<T>, +IComponentLambda<T, WFloat, U>>(
        self: @Vector, lambda: T
    ) -> Span<U> {
        let mut result = ArrayTrait::new();
        let content = *(self.content);

        let mut i = 0;
        loop {
            if i == content.len() {
                break ();
            }

            let component = lambda.apply(content.at(i));
            result.append(component);

            i += 1;
        };

        result.span()
    }

    fn from_raw_felt(values: @Span<felt252>) -> Vector {
        VectorBasics::from_lambda(values, RawFeltAsWFloat {})
    }

    // TODO:
    // fn from_raw_unsigned(value: u128) -> WFloat {
    //     WFloat { value: value.try_into().unwrap() }
    // }

    #[inline]
    fn from_raw_i128(values: @Span<i128>) -> Vector {
        VectorBasics::from_lambda(values, RawI128AsWFloat {})
    }

    #[inline]
    fn from_i128(values: @Span<i128>) -> Vector {
        VectorBasics::from_lambda(values, I128AsWFloat {})
    }

    #[inline]
    fn from_u128(values: @Span<u128>) -> Vector {
        VectorBasics::from_lambda(values, U128AsWFloat {})
    }

    #[inline]
    fn as_felt(self: @Vector) -> Span<felt252> {
        self.apply_extern(WFloatAsRawFelt {})
    }

    // Misc
    // -------------------------------------------------

    fn sum(self: @Vector) -> WFloat {
        let mut result = ZERO_WFLOAT;
        let mut i = 0;
        loop {
            if i == self.len() {
                break ();
            }
            result = result + self.at(i);
            i += 1;
        };
        result
    }

    fn mean(self: @Vector) -> WFloat {
        self.sum() / WFloatBasics::from_u64(self.len().into())
    }

    #[inline]
    fn scale(self: @Vector, factor: WFloat) -> Vector {
        self.apply(WFloatMultiplier { factor: factor })
    }

    #[inline]
    fn divide_by(self: @Vector, factor: WFloat) -> Vector {
        self.apply(WFloatDivider { factor: factor })
    }

    fn dot(self: @Vector, rhs: @Vector) -> WFloat {
        (*self * *rhs).sum()
    }

    fn norm(self: @Vector) -> WFloat {
        sqrt(self.dot(self))
    }

    fn normalize(self: @Vector) -> Vector {
        self.divide_by(self.norm())
    }

    // fn pow_monoid

    fn max(self: @Vector) -> WFloat {
        let mut max = (*self).at(0);
        let mut i = 0;
        loop {
            if i == self.len() {
                break ();
            }
            let current = (*self).at(i);
            max = function::max(current, max);
            i += 1;
        };
        max
    }

    fn argmax_vector(self: @Vector) -> Vector {
        let max = self.max();
        let mut content = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == self.len() {
                break ();
            }

            let current = (*self).at(i);
            if current == max {
                content.append(ONE_WFLOAT);
            } else {
                content.append(ZERO_WFLOAT);
            }

            i += 1;
        };
        Vector { content: content.span() }
    }

    // Returns the first occurence
    fn argmax(self: @Vector) -> usize {
        let max = self.max();
        let mut i = 0;

        loop {
            if i == self.len() {
                panic!("max not found");
            }

            let current = (*self).at(i);
            if current == max {
                break (i);
            }

            i += 1;
        }
    }

    // values between -1 and 1
    fn random(dimension: usize, seed: u64) -> Vector {
        let mut seed = seed;
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimension {
                break ();
            }
            result.append(normalize_lgn_rand_11(seed));
            seed = lcg_rand(seed);
            i += 1;
        };

        Vector { content: result.span() }
    }
}
