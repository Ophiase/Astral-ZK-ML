import json
import os

import eel
from starknet_py.net.full_node_client import FullNodeClient
from starknet_py.net.account.account import Account
from starknet_py.net.models.chains import StarknetChainId
from starknet_py.net.signer.stark_curve_signer import KeyPair
from starknet_py.contract import Contract
from starknet_py.cairo.felt import encode_shortstring
from starknet_py.common import create_sierra_compiled_contract
from starknet_py.common import create_casm_class
from starknet_py.hash.casm_class_hash import compute_casm_class_hash
from starknet_py.net.client_models import ResourceBounds, EstimatedFee, PriceUnit
from pprint import pprint

from typing import List, Optional, Tuple
from common import globalState

# import aioconsole
import asyncio

import numpy as np

from basic_conversions import wfloat, wfloat_to_float, to_hex, from_hex

# ----------------------------------------------------------------------

ACCOUNTS_PATH = os.path.join("data", "sepolia.json")

RESSOURCE_BOUND_COMMON = ResourceBounds(59806, 342990458309864)
RESOURCE_BOUND_UPDATE_PREDICTION = RESSOURCE_BOUND_COMMON
RESOURCE_BOUND_UPDATE_PROPOSITION = RESSOURCE_BOUND_COMMON
RESOURCE_BOUND_VOTE_FOR_A_PREDICTION = RESSOURCE_BOUND_COMMON

def retrieve_account_data() -> None:
    with open(ACCOUNTS_PATH, 'r') as file:
        data = json.load(file)

    globalState.validator_accounts = dict()
    globalState.bot_accounts = dict()
    
    validators_addresses = data["validators_addresses"]
    validators_private_keys = data["validators_private_keys"]
    bot_address = data["bot_address"]
    bot_private_key = data["bot_private_key"]

    for address, key in zip(validators_addresses, validators_private_keys) :
        globalState.validator_accounts[int(address, 16)] = Account(
                client=globalState.client,
                address=address,
                key_pair=KeyPair.from_private_key(key),
                chain=StarknetChainId.SEPOLIA)
    for address, key in zip (bot_address, bot_private_key) :
        globalState.bot_account = Account(
                client=globalState.client,
                address=address,
                key_pair=KeyPair.from_private_key(key),
                chain=StarknetChainId.SEPOLIA)
        
    # globalState.default_contract = asyncio.run(
    #     Contract.from_address(
    #             provider=globalState.validator_accounts[int(validators_addresses[0], 16)], 
    #             address=globalState.DEPLOYED_ADDRESS
    #     ))


# ----------------------------------------------------------------------

# def address_to_bot_index(address : int) -> int:
#     '''
#     Converts an address to the corresponding index
#     '''
#     bot_list = call_bot_list()
#     for index, bot in enumerate(bot_list) :
#         if bot == address : return index
#     raise IndexError()

# def bot_index_to_address(index : int) -> int:
#     '''
#     Converts an index to the corresponding address
#     '''
#     return int(call_bot_list()[index], 16)

# def address_to_validator_index(address : int) -> int:
#     '''
#     Converts an address to the corresponding index
#     '''
#     validator_list = call_validator_list()
#     for index, validator in enumerate(validator_list) :
#         if validator == address : return index
#     raise IndexError()

# def validator_index_to_address(index : int) -> int:
#     '''
#     Converts an index to the corresponding address
#     '''
#     return int(call_validator_list()[index], 16)


# ----------------------------------------------------------------------
# CALL
# ----------------------------------------------------------------------

def call_generic(function_name : str) :
    contract = globalState.default_contract
    return asyncio.run(
        contract.functions[function_name].call()
    )[0]

# def call_something() -> np.array :
#     value = call_generic('something')
#     globalState.remote_something = [fwsad_to_float(x) for x in value]
#     return globalState.something

# ----------------------------------------------------------------------
# INVOKE
# ----------------------------------------------------------------------

# ADD PREDICTION INVOKE

def invoke_predict(prediction: np.array, debug=False) :
    account = globalState.bot_account

    contract = asyncio.run(
        Contract.from_address(
                provider=account, 
                address=globalState.DEPLOYED_ADDRESS
    ))

    inputs_as_felt = [
       [ wfloat(x) for x in line ] for line in prediction
    ]


    eel.writeToConsole("Try predict ..")

    # fn predict(ref self: TContractState, inputs: Matrix, for_storage: bool) -> Matrix;
    result = asyncio.run(
        contract.functions["predict"].invoke_v3(
            inputs=inputs_as_felt, for_storage=True, 
            l1_resource_bounds=RESOURCE_BOUND_UPDATE_PREDICTION
        )
    )

    eel.writeToConsole("Succeed")
    eel.setSepoliaConsole(
        f"Onchain result:\n{result}"
    )