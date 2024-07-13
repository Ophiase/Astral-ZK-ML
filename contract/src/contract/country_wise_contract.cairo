
use starknet::ContractAddress;
use super::super::math::matrix::{Matrix};

#[starknet::interface]
pub trait ICountryWiseContract<TContractState> {
    fn predict(ref self: TContractState, inputs : Matrix, for_storage : bool) -> Matrix;
}

#[starknet::contract]
pub mod CountryWiseContract {
    use core::array::ArrayTrait;
    use astral_zkml::math::ml::ILayer;
    use core::array::SpanTrait;
    use astral_zkml::math::matrix::IMatrixBasics;
    use astral_zkml::math::vector::IVectorBasics;
    use starknet::ContractAddress;
    use astral_zkml::math::wfloat::{WFloat};
    use astral_zkml::math::vector::{Vector, VectorBasics};
    use astral_zkml::math::matrix::{Matrix, MatrixBasics};
    use astral_zkml::math::ml::{
        LayerType, ActivationFunction, SGD, DEFAULT_SGD,
        SerializedLayerIndex, SerializedLayerContent,
        Sequential, SequentialBasics, DenseLayer, DenseLayerBasics
    };

    #[storage]
    struct Storage {
        dimension: (usize, usize),

        model_size: usize,
        model_optimizer: SGD,
        model_content: LegacyMap<(usize, SerializedLayerIndex), SerializedLayerContent>
    }

    // DIRTY PART (waiting for starknet-2.7.2 to store the network properly)
    // ------------------------------------------------------------------------------------

    fn save_biaises(ref self: ContractState, which_layer : usize, biais : Vector) {
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

        save_biaises(ref self, which_layer, layer.biaises);
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

        self.model_optimizer.write(model.optimizer);
    }

    // -------------------------------
    
    fn read_biaises(self: @ContractState, which_layer : usize, shape : usize) -> Vector {
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == shape { break(); }
            let w = match self.model_content.read((which_layer, SerializedLayerIndex::Biais(i) )) {
                SerializedLayerContent::Weight(x) => x,
                _ => panic!("Storage corrupted")
            };
            result.append(w);
            i += 1;
        };
        Vector { content: result.span() }
    }

    fn read_weights(self: @ContractState, which_layer : usize, dimX : usize, dimY : usize) -> Matrix {
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX { break(); }
            let mut sub_result = ArrayTrait::new();
            let mut j = 0;
            loop {
                if j == dimY { break(); }
                let w = match self.model_content.read((which_layer, SerializedLayerIndex::Weights((i, j)) )) {
                    SerializedLayerContent::Weight(x) => x,
                    _ => panic!("Storage corrupted")
                };
                sub_result.append(w);
                j += 1;
            };
            result.append(Vector{content:sub_result.span()});
            i += 1;
        };

        Matrix { content: result.span() }
    }

    fn read_layer(self: @ContractState, which_layer : usize) ->  
        (Matrix, Vector, ActivationFunction)
    {
        let dimX = match self.model_content.read(( which_layer, SerializedLayerIndex::InputSize )) {
            SerializedLayerContent::InputSize(x) => x,
            _ => panic!("Storage corrupted")
        };
        let dimY = match self.model_content.read(( which_layer, SerializedLayerIndex::OutputSize )) {
            SerializedLayerContent::InputSize(x) => x,
            _ => panic!("Storage corrupted")
        };
        
        let biaises = read_biaises(self, which_layer, dimY);
        let weights = read_weights(self, which_layer, dimX, dimY);
        
        let activation = match self.model_content.read(
            (which_layer, SerializedLayerIndex::ActivationFunction )
        ) {
            SerializedLayerContent::ActivationFunction(x) => x,
            _ => panic!("Storage corrupted")
        };

        (
            weights,
            biaises,
            activation
        )
    }

    // -------------------------------

    fn read_model(self: @ContractState) -> Sequential {
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == self.model_size.read() { break(); }
            result.append(read_layer(self, i));
            i += 1;
        };
        SequentialBasics::init_from_storage(
            layers: result.span(),
            optimizer: self.model_optimizer.read()
        )
    }

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
            assert!(!for_storage, "not implemented yet");
            let mut model = read_model(@self);
            model.forward(@inputs)
        }
    }
}
