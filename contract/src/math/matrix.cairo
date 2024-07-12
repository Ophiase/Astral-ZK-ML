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
    WFloat, WFloatBasics,
    ZERO_WFLOAT, ONE_WFLOAT, NEG_WFLOAT, HALF_WFLOAT, DECIMAL_WFLOAT, 
};
use super::vector::{
    Vector, VectorBasics
};
use super::component_lambda::{
    IComponentLambda,
    RawFeltAsWFloat, RawI128AsWFloat, I128AsWFloat, U128AsWFloat, WFloatAsRawFelt
};

use super::algebra::{
    NeutralElement, Invertible,
    pow, pow_monoid
};

// -------------------------------------------------
// MATRIX
// -------------------------------------------------

#[derive(PartialEq, Drop, Copy, Serde)] //, Hash, starknet::Store)]
pub struct Matrix {
    pub content: Span<Vector>
}

// -------------------------------------------------

fn matrix_to_string(matrix: @Matrix) -> ByteArray {
    let mut result : ByteArray = "";
    let mut i = 0;
    loop {
        if i == matrix.dimX() {
            break ();
        }
        let vector = (*matrix.content).at(i);
        result.append(@format!("{vector}\n"));
        i += 1
    };
    result
}

pub impl MatrixDisplay of Display<Matrix> {
    fn fmt(self: @Matrix, ref f: Formatter) -> Result<(), Error> {
        write!(f, "{}", matrix_to_string(self))
    }
}

// ARITHMETIC
// -------------------------------------------------

pub impl MatrixAdd of Add<Matrix> {
    fn add(lhs: Matrix, rhs: Matrix) -> Matrix {
        assert!(
            lhs.shape() == rhs.shape(), 
            "add error: different size"
        );

        let (dimX, _) = lhs.shape(); 

        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            let left_content : Vector = lhs.get_ith_line(i);
            let right_content : Vector = rhs.get_ith_line(i);
            
            result.append(
                left_content + right_content
            
            );
            i += 1;
        };

        Matrix { content: result.span() }
    }
}

pub impl MatrixSub of Sub<Matrix> {
    fn sub(lhs: Matrix, rhs: Matrix) -> Matrix {
        assert!(
            lhs.shape() == rhs.shape(), 
            "add error: different size"
        );

        let (dimX, _) = lhs.shape(); 

        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            let left_content : Vector = lhs.get_ith_line(i);
            let right_content : Vector = rhs.get_ith_line(i);
            
            result.append(
                left_content - right_content
            
            );
            i += 1;
        };

        Matrix { content: result.span() }
    }
}

pub impl MatrixMul of Mul<Matrix> {
    fn mul(lhs: Matrix, rhs: Matrix) -> Matrix {
        assert!(
            lhs.shape() == rhs.shape(), 
            "add error: different size"
        );

        let (dimX, _) = lhs.shape(); 

        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            let left_content : Vector = lhs.get_ith_line(i);
            let right_content : Vector = rhs.get_ith_line(i);
            
            result.append(
                left_content * right_content
            
            );
            i += 1;
        };

        Matrix { content: result.span() }
    }
}

pub impl MatrixDiv of Div<Matrix> {
    fn div(lhs: Matrix, rhs: Matrix) -> Matrix {
        assert!(
            lhs.shape() == rhs.shape(), 
            "add error: different size"
        );

        let (dimX, _) = lhs.shape(); 

        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            let left_content : Vector = lhs.get_ith_line(i);
            let right_content : Vector = rhs.get_ith_line(i);
            
            result.append(
                left_content / right_content
            
            );
            i += 1;
        };

        Matrix { content: result.span() }
    }
}

// -------------------------------------------------

#[generate_trait]
pub impl MatrixBasics of IMatrixBasics {

    #[inline]
    fn shape(self: @Matrix) -> (usize, usize) {
        (self.dimX(), self.dimY())
    }

    #[inline]
    fn dimX(self: @Matrix) -> usize {
        (*self).content.len()
    }

    #[inline]
    fn dimY(self: @Matrix) -> usize {
        (*self).content.at(0).len()
    }

    // Constructors
    // -------------------------------------------------

    fn fill(shape: (usize, usize), value: @WFloat) -> Matrix {
        let (dimX, dimY) = shape;        
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            result.append( VectorBasics::fill(dimY, value) );
            i += 1;
        };

        Matrix { content: result.span() }
    }

    #[inline]
    fn one(shape: (usize, usize)) -> Matrix {
        MatrixBasics::fill(shape, @ONE_WFLOAT)
    }

    #[inline]
    fn zero(shape: (usize, usize)) -> Matrix {
        MatrixBasics::fill(shape, @ZERO_WFLOAT)
    }

    fn identity(shape : (usize, usize)) -> Matrix {
        let (dimX, dimY) = shape;
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            result.append(VectorBasics::one_one(dimY, i));
            i += 1;
        };
        Matrix { content: result.span() }
    }

    fn apply<
        T, +Copy<T>, +Drop<T>, +IComponentLambda<T, WFloat, WFloat>
    >(
        self: @Matrix, lambda: T
    ) -> Matrix {
        let dimX = self.dimX();
        let dimY = self.dimY();

        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            let content = self.get_ith_line(i).content;
            let mut sub_result = ArrayTrait::new();
            let mut j = 0;
            loop {
                if j == dimY { break(); }

                let component = lambda.apply(content.at(j));
                sub_result.append(component);

                j += 1;
            };
            
            result.append(
                Vector { content: sub_result.span() }
            );
            i += 1;
        };
        Matrix { content: result.span() }
    }

    fn from_lambda<
        T, U,
        +Copy<T>, +Drop<T>, +Destruct<T>, +IComponentLambda<T, U, WFloat>>(
        content : @Span<Span<U>>, lambda: T
    ) -> Matrix {
        let dimX = (*content).len();
        let dimY = (*(*content).at(0)).len();

        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            let content : Span<U> = (*(*content).at(i));
            let mut sub_result = ArrayTrait::new();
            let mut j = 0;
            loop {
                if j == dimY { break(); }

                let component = lambda.apply(content.at(j));
                sub_result.append(component);

                j += 1;
            };
            
            result.append(
                Vector { content: sub_result.span() }
            );
            i += 1;
        };
        Matrix { content: result.span() }
    }

    fn apply_extern<
        T, U,
        +Drop<U>, +Copy<T>,
        +Drop<T>, +Destruct<T>, +IComponentLambda<T, WFloat, U>
    >(
        self: @Matrix, lambda: T
    ) -> Span<Span<U>> {
        let dimX = self.dimX();
        let dimY = self.dimY();

        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            let content = self.get_ith_line(i).content;
            let mut sub_result = ArrayTrait::new();
            let mut j = 0;
            loop {
                if j == dimY { break(); }

                let component = lambda.apply(content.at(j));
                sub_result.append(component);

                j += 1;
            };

            result.append(sub_result.span());
            i += 1;
        };

        result.span()
    }

    fn from_row_vector(vector : @Vector) -> Matrix {
        Matrix { content: array![*vector].span() }
    }

    fn from_line_vector(vector : @Vector) -> Matrix {
        MatrixBasics::from_row_vector(vector).transpose()
    }

    // Returns the first basis
    fn to_vector(self : @Matrix) -> Vector {
        self.get_ith_basis(0)
    }

    fn from_raw_felt(values: @Span<Span<felt252>>) -> Matrix {
        MatrixBasics::from_lambda(values, RawFeltAsWFloat{})
    }

    // TODO:
    // fn from_raw_unsigned(value: u128) -> WFloat {
    //     WFloat { value: value.try_into().unwrap() }
    // }

    #[inline]
    fn from_raw_i128(values: @Span<Span<i128>>) -> Matrix {
        MatrixBasics::from_lambda(values, RawI128AsWFloat{})
    }

    #[inline]
    fn from_i128(values: @Span<Span<i128>>) -> Matrix {
        MatrixBasics::from_lambda(values, I128AsWFloat{})
    }

    #[inline]
    fn from_u128(values: @Span<Span<u128>>) -> Matrix {
        MatrixBasics::from_lambda(values, U128AsWFloat{})
    }

    #[inline]
    fn as_felt(self: @Matrix) -> Span<Span<felt252>> {
        self.apply_extern(WFloatAsRawFelt {})
    }

    // Additional Operations
    // -------------------------------------------------

    #[inline]
    fn at(self : @Matrix, i: usize, j: usize) -> WFloat {
        (*self).content.at(i).at(j)
    }

    #[inline]
    fn get_ith_line(self: @Matrix, ith_line: usize) -> Vector {
        *(*self).content.at(ith_line)
    }

    // M = [v_1, ... v_i ... v_n] -> v_i
    fn get_ith_basis(self: @Matrix, ith_dimension: usize) -> Vector {
        let mut result = ArrayTrait::new();
        let dimX = self.dimX();
        
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            result.append( self.at(i, ith_dimension) );
            i += 1;
        };
        
        Vector { content: result.span() }
    }

    fn transpose(self : @Matrix) -> Matrix {
        let (dimX, dimY) = self.shape();        
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            result.append( self.get_ith_basis(dimY) );
            i += 1;
        };
        Matrix { content: result.span() }
    }

    // fn mul_vector(self : @Matrix, vector : @Vector) -> Vector {
    //     let (dimX, dimY) = self.shape();
    //     let result = VectorBasics::zero(dimX);

    //     let mut i = 0;
    //     loop {
    //         if i == vector.len() { break(); }
    //         let current = *vector.at(i);
            
            
    //         i += 1;
    //     };
    // }
    
    // fn naive_dot(self : @Matrix, @Matrix) -> Matrix
}
