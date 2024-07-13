
use starknet::ContractAddress;
use super::super::math::matrix::{Matrix};

#[starknet::interface]
pub trait ICountryWiseContract<TContractState> {
    fn predict(ref self: TContractState, inputs : Matrix, for_storage : bool) -> Matrix;
    
    // fn update_prediction(ref self: TContractState, prediction : FeltVector);
}

#[starknet::contract]
pub mod CountryWiseContract {
    use astral_zkml::math::ml::ILayer;
use core::array::SpanTrait;
use astral_zkml::math::matrix::IMatrixBasics;
use astral_zkml::math::vector::IVectorBasics;
use starknet::ContractAddress;
    use astral_zkml::math::wfloat::{WFloat};
    use astral_zkml::math::vector::{Vector, VectorBasics};
    use astral_zkml::math::matrix::{Matrix, MatrixBasics};
    use astral_zkml::math::ml::{
        LayerType, ActivationFunction, DEFAULT_SGD,
        SerializedLayerIndex, SerializedLayerContent,
        Sequential, SequentialBasics, DenseLayer, DenseLayerBasics
    };

    #[storage]
    struct Storage {
        dimension: (usize, usize),

        model_size: usize,
        model_content: LegacyMap<(usize, SerializedLayerIndex), SerializedLayerContent>
    }

    // DIRTY PART (waiting for starknet-2.7.2 to store the network properly)
    // ------------------------------------------------------------------------------------

    fn save_biais(ref self: ContractState, which_layer : usize, biais : Vector) {
        let mut i = 0;
        loop {
            if i == biais.len() { break(); }
            self.model_content.write(
                (which_layer, SerializedLayerIndex::Biais(i) ),
                SerializedLayerContent::Weight(biais.at(i))
            );
            i += 1;
        };
    }

    fn save_weights(ref self: ContractState, which_layer : usize, weights : Matrix) {
        let (dimX, dimY) = weights.shape();
        let mut i = 0;
        loop {
            if i == dimX { break(); }

            let mut j = 0;
            loop {
                if j == dimY { break(); }

                self.model_content.write(
                    (which_layer, SerializedLayerIndex::Weights((i, j)) ),
                    SerializedLayerContent::Weight( weights.at(i, j) )
                );  
                j += 1;
            };
            i += 1;
        };
    }

    fn save_layer(ref self: ContractState, which_layer : usize, layer : DenseLayer) {
        self.model_content.write(
            ( which_layer, SerializedLayerIndex::InputSize ),
            SerializedLayerContent::InputSize( layer.get_input_shape() )
        );  
        
        self.model_content.write(
            ( which_layer, SerializedLayerIndex::OutputSize ),
            SerializedLayerContent::OutputSize( layer.get_output_shape() )
        );  

        save_biais(ref self, which_layer, layer.biaises);
        save_weights(ref self, which_layer, layer.weights);
        
        self.model_content.write(
            ( which_layer, SerializedLayerIndex::ActivationFunction ),
            SerializedLayerContent::ActivationFunction( layer.activation_function )
        );
    }

    // -------------------------------

    fn save_model(ref self: ContractState, model : Sequential) {
        let mut i = 0;
        loop {
            if i == model.layers.len() { break(); }
            save_layer(ref self, i, *(model.layers.at(i)) );
            i += 1;
        };
    }

    // -------------------------------
    // fn read_biais(self: @ContractState, which_layer : usize) -> Vector {
    //     let mut i = 0;
    //     loop {
    //         if i == biais.len() { break(); }
    //         self.model_content.write(
    //             (which_layer, SerializedLayerIndex::Biais(i) ),
    //             SerializedLayerContent::Weight(biais.at(i))
    //         );
    //         i += 1;
    //     };
    // }

    // fn read_weights(self: ContractState, which_layer : usize) -> Matrix {
    //     let (dimX, dimY) = weights.shape();
    //     let mut i = 0;
    //     loop {
    //         if i == dimX { break(); }

    //         let mut j = 0;
    //         loop {
    //             if j == dimY { break(); }

    //             self.model_content.write(
    //                 (which_layer, SerializedLayerIndex::Weights((i, j)) ),
    //                 SerializedLayerContent::Weight( weights.at(i, j) )
    //             );  
    //             j += 1;
    //         };
    //         i += 1;
    //     };
    // }

    // fn read_layer(ref self: ContractState, which_layer : usize) -> DenseLayer {
    //     self.model_content.write(
    //         ( which_layer, SerializedLayerIndex::InputSize ),
    //         SerializedLayerContent::InputSize( layer.get_input_shape() )
    //     );  
        
    //     self.model_content.write(
    //         ( which_layer, SerializedLayerIndex::OutputSize ),
    //         SerializedLayerContent::OutputSize( layer.get_output_shape() )
    //     );  

    //     save_biais(ref self, which_layer, layer.biaises);
    //     save_weights(ref self, which_layer, layer.weights);
        
    //     self.model_content.write(
    //         ( which_layer, SerializedLayerIndex::ActivationFunction ),
    //         SerializedLayerContent::ActivationFunction( layer.activation_function )
    //     );
    // }

    // -------------------------------

    // fn read_model(self: @ContractState) -> Sequential {
        
    // }

    // ------------------------------------------------------------------------------------

    #[constructor]
    fn constructor(ref self: ContractState, 
        raw_model: Span<(
            Span<Span<felt252>>, Span<felt252>, ActivationFunction
        )>) 
    {
        let _model = SequentialBasics::init_from_felt252(
            raw_model, DEFAULT_SGD
        );


    }

    #[abi(embed_v0)]
    impl ContractImpl of super::ICountryWiseContract<ContractState> {
        fn predict(ref self: ContractState, inputs : Matrix, for_storage : bool) -> Matrix {
            panic!("Not implemented yet!");
            
            // TODO: deserialize neural network
            // model.forward(inputs)
            inputs
        }
    }
}
