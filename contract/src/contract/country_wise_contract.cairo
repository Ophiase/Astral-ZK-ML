use starknet::ContractAddress;
use super::super::math::matrix::{Matrix};

#[starknet::interface]
pub trait ICountryWiseContract<TContractState> {
    // USER SIDE
    // ---------------

    fn predict(ref self: TContractState, inputs: Matrix, for_storage: bool) -> Matrix;

    // VALIDATOR SIDE
    // ---------------

    // fn get_filtered_epoch
    // fn get_propositions

    fn evaluate_stored_prediction(
        ref self: TContractState, which: usize, evaluation: Option<Span<felt252>>
    );

    // MANAGEMENT
    // ---------------

    // fn get_validator_list(self: @TContractState) -> Array<ContractAddress>;
    // fn get_countries_list(self: @TContractState) -> Array<felt252>;

    // fn update_proposition(ref self: TContractState, proposition : Option<(usize, ContractAddress)>);
    // fn vote_for_a_proposition(ref self: TContractState, which_validator : usize, support_his_proposition : bool);

    // fn get_replacement_propositions(self: @TContractState) -> Array<Option<(usize, ContractAddress)>>;
    // fn get_a_specific_proposition(self: @TContractState, which_admin : usize) -> Option<(usize, ContractAddress)>;

    // MISC
    // ---------------

    fn get_n_proposed(self: @TContractState) -> usize;
    fn get_max_propositions(self: @TContractState) -> usize;
    fn get_min_filtered(self: @TContractState) -> usize;
}

#[starknet::contract]
pub mod CountryWiseContract {
    use starknet::get_caller_address;
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
        LayerType, ActivationFunction, SGD, DEFAULT_SGD, SerializedLayerIndex,
        SerializedLayerContent, Sequential, SequentialBasics, DenseLayer, DenseLayerBasics
    };

    // ------------------------------------------------------------------------------------

    #[derive(Drop, Serde, starknet::Store, Hash)]
    pub struct VoteCoordinate {
        vote_emitter: usize,
        vote_receiver: usize
    }

    #[derive(Drop, Serde, starknet::Store, Copy, Hash)]
    enum PredictionIndex {
        Author,
        WhichComponent: usize
    }

    #[derive(Drop, Serde, starknet::Store, Copy, Hash)]
    enum PredictionData {
        Author: ContractAddress,
        Data: WFloat
    }

    #[derive(Drop, Serde, starknet::Store, Copy, Hash)]
    enum IndexVote {
        Absurd: usize,
        WantedResult: (usize, usize)
    }

    #[derive(Drop, Serde, starknet::Store, Copy, Hash)]
    enum VoteData {
        Absurd: bool,
        Data: WFloat
    }

    // ------------------------------------------------------------------------------------

    #[storage]
    struct Storage {
        // MODEL
        model_size: usize,
        model_optimizer: SGD,
        model_content: LegacyMap<(usize, SerializedLayerIndex), SerializedLayerContent>,
        // TRAINING MANAGEMENT
        max_propositions: usize,
        n_proposed: usize,
        propositions: LegacyMap<(usize, PredictionIndex), PredictionData>,
        training_vote_matrix: LegacyMap<IndexVote, VoteData>,
        min_filtered: usize,
        n_filtered: usize,
        filtered: LegacyMap<(usize, PredictionIndex), PredictionData>,
        // ADMINISTRATION
        n_countries: usize,
        countries_id: LegacyMap<usize, felt252>,
        countries_scores: LegacyMap<usize, WFloat>,
        n_validators: usize,
        validators: LegacyMap<usize, (ContractAddress, usize)>,
        replacement_vote_matrix: LegacyMap<VoteCoordinate, bool>,
        replacement_propositions: LegacyMap<usize, Option<(usize, ContractAddress)>>,
    }

    // DIRTY PART (waiting for starknet-2.7.2 to store the network properly)
    // ------------------------------------------------------------------------------------

    fn save_biaises(ref self: ContractState, which_layer: usize, biais: Vector) {
        let mut i = 0;
        loop {
            if i == biais.len() {
                break ();
            }
            self
                .model_content
                .write(
                    (which_layer, SerializedLayerIndex::Biais(i)),
                    SerializedLayerContent::Weight(biais.at(i))
                );
            i += 1;
        };
    }

    fn save_weights(ref self: ContractState, which_layer: usize, weights: Matrix) {
        let (dimX, dimY) = weights.shape();
        let mut i = 0;
        loop {
            if i == dimX {
                break ();
            }

            let mut j = 0;
            loop {
                if j == dimY {
                    break ();
                }

                self
                    .model_content
                    .write(
                        (which_layer, SerializedLayerIndex::Weights((i, j))),
                        SerializedLayerContent::Weight(weights.at(i, j))
                    );
                j += 1;
            };
            i += 1;
        };
    }

    fn save_layer(ref self: ContractState, which_layer: usize, layer: DenseLayer) {
        self
            .model_content
            .write(
                (which_layer, SerializedLayerIndex::InputSize),
                SerializedLayerContent::InputSize(layer.get_input_shape())
            );

        self
            .model_content
            .write(
                (which_layer, SerializedLayerIndex::OutputSize),
                SerializedLayerContent::OutputSize(layer.get_output_shape())
            );

        save_biaises(ref self, which_layer, layer.biaises);
        save_weights(ref self, which_layer, layer.weights);

        self
            .model_content
            .write(
                (which_layer, SerializedLayerIndex::ActivationFunction),
                SerializedLayerContent::ActivationFunction(layer.activation_function)
            );
    }

    // -------------------------------

    fn save_model(ref self: ContractState, model: Sequential) {
        let n = model.layers.len();
        self.model_size.write(n);
        let mut i = 0;
        loop {
            if i == n {
                break ();
            }
            save_layer(ref self, i, *(model.layers.at(i)));
            i += 1;
        };

        self.model_optimizer.write(model.optimizer);
    }

    // -------------------------------

    fn read_biaises(self: @ContractState, which_layer: usize, shape: usize) -> Vector {
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == shape {
                break ();
            }
            let w = match self.model_content.read((which_layer, SerializedLayerIndex::Biais(i))) {
                SerializedLayerContent::Weight(x) => x,
                _ => panic!("Storage corrupted")
            };
            result.append(w);
            i += 1;
        };
        Vector { content: result.span() }
    }

    fn read_weights(self: @ContractState, which_layer: usize, dimX: usize, dimY: usize) -> Matrix {
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == dimX {
                break ();
            }
            let mut sub_result = ArrayTrait::new();
            let mut j = 0;
            loop {
                if j == dimY {
                    break ();
                }
                let w =
                    match self
                        .model_content
                        .read((which_layer, SerializedLayerIndex::Weights((i, j)))) {
                    SerializedLayerContent::Weight(x) => x,
                    _ => panic!("Storage corrupted")
                };
                sub_result.append(w);
                j += 1;
            };
            result.append(Vector { content: sub_result.span() });
            i += 1;
        };

        Matrix { content: result.span() }
    }

    fn read_layer(
        self: @ContractState, which_layer: usize
    ) -> (Matrix, Vector, ActivationFunction) {
        let dimX = match self.model_content.read((which_layer, SerializedLayerIndex::InputSize)) {
            SerializedLayerContent::InputSize(x) => x,
            _ => panic!("Storage corrupted")
        };
        let dimY = match self.model_content.read((which_layer, SerializedLayerIndex::OutputSize)) {
            SerializedLayerContent::OutputSize(x) => x,
            _ => panic!("Storage corrupted")
        };

        let biaises = read_biaises(self, which_layer, dimY);
        let weights = read_weights(self, which_layer, dimX, dimY);

        let activation =
            match self.model_content.read((which_layer, SerializedLayerIndex::ActivationFunction)) {
            SerializedLayerContent::ActivationFunction(x) => x,
            _ => panic!("Storage corrupted")
        };

        (weights, biaises, activation)
    }

    // -------------------------------

    fn read_model(self: @ContractState) -> Sequential {
        let mut result = ArrayTrait::new();
        let mut i = 0;
        loop {
            if i == self.model_size.read() {
                break ();
            }
            result.append(read_layer(self, i));
            i += 1;
        };
        SequentialBasics::init_from_storage(
            layers: result.span(), optimizer: self.model_optimizer.read()
        )
    }

    // ------------------------------------------------------------------------------------

    fn find_validator_index(self: @ContractState, validator: @ContractAddress) -> Option<usize> {
        let mut i = 0;
        loop {
            if i == self.n_validators.read() {
                break (Option::None);
            }

            let (address, _which_country) = self.validators.read(i);

            if address == *validator {
                break (Option::Some(i));
            }

            i += 1;
        }
    }

    fn is_validator(self: @ContractState, validator: @ContractAddress) -> bool {
        match find_validator_index(self, validator) {
            Option::None => false,
            Option::Some(_x) => true
        }
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        max_propositions: usize,
        min_filtered: usize,
        countries: Span<felt252>,
        initial_validators: Span<ContractAddress>,
        initial_validators_countries: Span<usize>,

        raw_model: Span<(Span<Span<felt252>>, Span<felt252>, ActivationFunction)>
    ) {
        let model = SequentialBasics::init_from_felt252(raw_model, DEFAULT_SGD);
        save_model(ref self, model);
        
        // TODO:
        // n_proposed : usize,
    }


    #[abi(embed_v0)]
    impl ContractImpl of super::ICountryWiseContract<ContractState> {
        fn predict(ref self: ContractState, inputs: Matrix, for_storage: bool) -> Matrix {
            if for_storage {
                match find_validator_index(@self, @get_caller_address()) {
                    Option::Some(_idx) => panic!("not implemented yet"),
                    Option::None => panic!("not a validator")
                };
            }

            let mut model = read_model(@self);
            model.forward(@inputs)
        }

        fn evaluate_stored_prediction(
            ref self: ContractState, which: usize, evaluation: Option<Span<felt252>>
        ) {
            panic!("not_implemented yet");
        }

        fn get_n_proposed(self: @ContractState) -> usize {
            self.n_proposed.read()
        }
        fn get_max_propositions(self: @ContractState) -> usize {
            self.max_propositions.read()
        }
        fn get_min_filtered(self: @ContractState) -> usize {
            self.min_filtered.read()
        }
    }
}
