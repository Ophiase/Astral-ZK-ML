# Off Chain interaction with the decentralized model

- ``main.py`` : Web demonstration of the smart contract on Sepolia.
    - Simulate validators and bots

## Installation

Required :
- python3 : eel

### Fill the following files (create them if necessary) :

``data/contract_info.json``
```json
{
    "rpc": "https://free-rpc.nethermind.io/sepolia-juno",
    "declared_address" : "<INSERT>",
    "deployed_address" : "<INSERT>"
}
```

Declaration/Deployment explained in [contract/README.md](oracle_contract/README.md)

``data/sepolia.json``
```json
{
    "validators_addresses": [
        "<INSERT>",
        "<INSERT>",
        "<INSERT>"
    ],
    "validators_private_keys": [
        "<INSERT>",
        "<INSERT>",
        "<INSERT>"
    ],
    "bot_address" : [ "<INSERT>" ],
    "bot_key": [ "<INSERT>" ]
}
```

It's not safe to put your private keys in a json file. \
We assume you are using test accounts specificaly for Sepolia.

## Execution

```bash
python3 main.py
```