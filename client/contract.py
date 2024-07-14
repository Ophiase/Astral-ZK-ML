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

# ----------------------------------------------------------------------

ACCOUNTS_PATH = os.path.join("data", "sepolia.json")

RESSOURCE_BOUND_COMMON = ResourceBounds(259806, 153060543928007)
RESOURCE_BOUND_UPDATE_PREDICTION = RESSOURCE_BOUND_COMMON
RESOURCE_BOUND_UPDATE_PROPOSITION = RESSOURCE_BOUND_COMMON
RESOURCE_BOUND_VOTE_FOR_A_PREDICTION = RESSOURCE_BOUND_COMMON


UPPER_BOUND_FELT252 = 3618502788666131213697322783095070105623107215331596699973092056135872020481
UPPER_BOUND__I128 = (2**127) - 1 # included

# ----------------------------------------------------------------------

# fwsad for wsad as felt252
def fwsad_to_float(x) :
    return float(
        (x - UPPER_BOUND_FELT252) if x > UPPER_BOUND__I128 \
        else x
    ) * 1e-6

# fwsad for wsad as felt252
def float_to_fwsad(x) :
    as_wsad = int(x*1e6)
    return (
        as_wsad + UPPER_BOUND_FELT252 if as_wsad < 0 \
        else as_wsad
    )

def to_hex(x: int) -> str:
    return f"0x{x:0x}"

def from_hex(x : str) -> int:
    return int(x, 16)

def retrieve_account_data():
    with open(ACCOUNTS_PATH, 'r') as file:
        data = json.load(file)

    globalState.admin_accounts = dict()
    globalState.oracle_accounts = dict()
    
    admins_addresses = data["admins_addresses"]
    admins_private_keys = data["admins_private_keys"]
    oracles_addresses = data["oracles_addresses"]
    oracles_private_keys = data["oracles_private_keys"]

    for address, key in zip(admins_addresses, admins_private_keys) :
        globalState.admin_accounts[int(address, 16)] = Account(
                client=globalState.client,
                address=address,
                key_pair=KeyPair.from_private_key(key),
                chain=StarknetChainId.SEPOLIA)
    for address, key in zip (oracles_addresses, oracles_private_keys) :
        globalState.oracle_accounts[int(address, 16)] = Account(
                client=globalState.client,
                address=address,
                key_pair=KeyPair.from_private_key(key),
                chain=StarknetChainId.SEPOLIA)

    globalState.default_contract = asyncio.run(
        Contract.from_address(
                provider=globalState.admin_accounts[int(admins_addresses[0], 16)], 
                address=globalState.DEPLOYED_ADDRESS
        ))


# ----------------------------------------------------------------------

def address_to_oracle_index(address : int) -> int:
    '''
    Converts an address to the corresponding index
    '''
    oracle_list = call_oracle_list()
    for index, oracle in enumerate(oracle_list) :
        if oracle == address : return index
    raise IndexError()

def oracle_index_to_address(index : int) -> int:
    '''
    Converts an index to the corresponding address
    '''
    return int(call_oracle_list()[index], 16)

def address_to_admin_index(address : int) -> int:
    '''
    Converts an address to the corresponding index
    '''
    admin_list = call_admin_list()
    for index, admin in enumerate(admin_list) :
        if admin == address : return index
    raise IndexError()

def admin_index_to_address(index : int) -> int:
    '''
    Converts an index to the corresponding address
    '''
    return int(call_admin_list()[index], 16)



# ----------------------------------------------------------------------
# CALL
# ----------------------------------------------------------------------

def call_generic(function_name : str) :
    contract = globalState.default_contract
    return asyncio.run(
        contract.functions[function_name].call()
    )[0]

def call_something() -> np.array :
    value = call_generic('something')
    globalState.remote_something = [fwsad_to_float(x) for x in value]
    return globalState.something

# ----------------------------------------------------------------------
# INVOKE
# ----------------------------------------------------------------------