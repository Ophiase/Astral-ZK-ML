# Smart Contracts

- ## Fully Decentralized Contract
    - TODO
- ## Country-Wise Decentralized Contract
    - TODO
- ## ZKML
    - ✅ MultiLayer Perceptron (Neural Network)
        - Implemented examples 
            - Star type predictions.
                - [Kaggle DataSet](https://www.kaggle.com/datasets/deepu1109/star-dataset)
    - ❌ Convolutional Neural Network
        - Requires to implements the following layers
            - Flatten, Conv2D, MaxPooling
        - Add the following examples :
            - Crater identification (availible datasets on kaggle)
    - ❌ Graph Attention Network (Neural Network)
        - Cannot be implemented on regular pipe
            - pipe : Labeled_Graph_Input $\to \dots \to$ Labeled_Graph $\to \dots \to$ Integer
        - Add the following examples :
            - Constellation identification
                - Requires a first model to extrapolate stars positions and size.
                - Normalized graph labeled with distances and star sizes.

## Installation

Requires : Scarb, Cairo

## Execution

Compilation :
```bash
scarb build
```

Tests :
```bash
scarb test
```

We recommand you to declare/deploy using Argent :

```bash
# EXAMPLE CALL DATA :

# TODO!!
```

Sepolia execution with a configured starkli :

```bash
# TO DECLARE THE CONTRACT :
starkli declare target/dev/  [TODO] .json --compiler-version=2.4.0
# or
starkli declare target/dev/<WANTED_CONTRACT>.json --compiler-version=2.4.0

# TO DEPLOY THE CONTRACT (ie. generate an instance) :
starkli deploy <CONTRACT_ADDRESS> <constructor as felt252>
```

```bash
# METHODS WITHOUT SIDE EFFECTS (READ ONLY) :
starkli call <CONTRACT_ADDRESS> <method> <arguments as felt252> 
# METHODS WITH SIDE EFFECTS :
starkli invoke <CONTRACT_ADDRESS> <method> <arguments as felt252> 
```

## Code details

The following basic features doesn't exists in the last stable version of Cairo :
- [Signed integer](src/math/signed.cairo) (eg: int)
    - I use the not supported i128 type.
    - It requires to be converted to felt252 when communicating with RPC
    - It requires to reimplement basics interfaces
- [Float](src/math/wfloat.cairo)
    - Starkware's team recommended me to use either :
        - alexandria or zkfloat
    - I instead use my own struct [WFloat](src/math/wfloat.cairo) 
- [Lambda]((src/math/component_lambda.cairo))
    - 12/07/24 : Unfortunaly not merged on the official Cairo repos ([PR link](https://github.com/starkware-libs/cairo/pull/6015))
    - My OOP Approach with interface ([link](src/math/component_lambda.cairo))
- Basic Linear Algebra (Vector + Matrix)
    - I implements them myself.
    - Smart contract integration
       - 12/07/24 : Merged 3 days ago by Starkware, but unfortunaly not availible on starknet yet ([PR link](https://github.com/starkware-libs/cairo/pull/5974))
       - I will have to do it the "dirty" way.
    - [Vector](src/math/vector.cairo)
    - [Matrix](src/math/matrix.cairo)