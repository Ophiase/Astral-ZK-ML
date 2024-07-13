
use starknet::ContractAddress;
use super::super::math::matrix::{Matrix};

#[starknet::interface]
pub trait ICountryWiseContract<TContractState> {
    fn predict(ref self: TContractState, inputs : Matrix, for_storage : bool) -> Matrix;
    
    // fn update_prediction(ref self: TContractState, prediction : FeltVector);
}

#[starknet::contract]
pub mod CountryWiseContract {
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
        model_content: LegacyMap<SerializedLayerIndex, SerializedLayerContent>
    }

    // DIRTY PART (waiting for starknet-2.7.2 to store the network properly)
    // ------------------------------------------------------------------------------------

    fn save_model(model : Sequential) {

    }

    // fn read_model() -> Sequential {
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
