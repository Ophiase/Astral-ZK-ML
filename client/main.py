from web_interface import init_server
import eel
import atexit
import subprocess
import atexit
import web_interface
import os
import argparse
from threading import Thread
from common import globalState
from contract import retrieve_account_data
from simulation_data import import_data

def main():
    parser = argparse.ArgumentParser(description="Oracle Scheduler")

    # parser.add_argument('--disable_sepolia', action='store_true', default=False, help='Do not load data/sepolia.json by default')
    # parser.add_argument('--disable_startup_fetch', action='store_true', default=False, help='Do not load data/sepolia.json by default')

    args = parser.parse_args()
    
    print("------------------------------------")

    if not os.path.exists(os.path.join("data", "sepolia.json")) :
        print("[Warning] : Offline mode - Did not find data/sepolia.json !")

    # if not args.disable_sepolia :

    retrieve_account_data()
    import_data()

    init_server()

    # eel.initComponents()

    # if not args.disable_sepolia :
        # eel.query("resume")
        # pass

    # if not args.disable_sepolia and not args.disable_startup_fetch :
        # eel.query("fetch")
        # pass

    while globalState.application_on :
        eel.sleep(3)

def cleanup(background_process) :
    background_process.terminate()
    background_process.wait()
    print("scraper terminated.")

if __name__ == "__main__":
    main()
