import json
import os
from starknet_py.net.full_node_client import FullNodeClient


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

        self.admin_accounts = None
        self.oracle_accounts = None
        self.default_contract = None


globalState = GlobalState()
