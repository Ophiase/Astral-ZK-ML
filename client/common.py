import json
import os
from starknet_py.net.full_node_client import FullNodeClient
import numpy as np

# ----------------------------------------------------------------------
# GLOBAL VARIABLES

class GlobalState:
    def __init__(self):
        self.application_on = True

        # -----------------------------

        with open(os.path.join('data', 'contract_info.json'), 'r') as file :
            data = json.load(file)
            self.RPC = data['rpc']
            self.DECLARED_ADDRESS = data['declared_address']
            self.DEPLOYED_ADDRESS = data['deployed_address']

        self.client = FullNodeClient(node_url=self.RPC)
        self.addresses = None
        self.private_keys = None

        self.validator_accounts = None
        self.bot_accounts = None
        self.default_contract = None

        self.train_X = None
        self.train_Y = None
        self.test_X = None
        self.test_Y = None

        self.current_sample = np.array([])

globalState = GlobalState()
