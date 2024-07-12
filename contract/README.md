# Smart Contracts

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
- Signed integer (eg: int)
    - I use the not supported i128 type.
    - It requires to be converted to felt252 when communicating with RPC
    - It requires to reimplement basics interfaces
- Float
    - Starkware's team recommended me to use either :
        - alexandria or zkfloat
    - I instead use my own struct WFloat 
- Lambda
    - OOP Approach with interface
