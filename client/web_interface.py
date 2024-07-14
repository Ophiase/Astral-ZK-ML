import eel
import time
from threading import Thread
from common import globalState

# ----------------------------------------------------------------------

HELP = '''
Commands :
    - help / clear / exit
    
    - fetch

    - auto_fetch on/off (default: off)
    - auto_commit on/off (default: off, ie. fetch => commit)
    - auto_resume on/off (default: off, ie. commit => resume)

    - contract_declaration_address
    - contract_address


For <validator> <bot> arguments, you can either specify the index in the contract or the address starting with "0x"

(S) indicates an interaction with Sepolia

---------------------------------------

'''

#     - set_component <component> (max : contract_dimension / local_prediction_dimension)

# ----------------------------------------------------------------------

def init_server():
    print("Starting graphical interface...")
    eel.init('web')
    eel.start('index.html',
            mode='default',
            host='localhost',
            block=False)

# ----------------------------------------------------------------------

def propositions_as_str(only_not_none = False) -> str:
    propositions = call_replacement_propositions()
    text = ""
    for index, proposition in enumerate(propositions) :
        if proposition is None :
            if not only_not_none:
                text += f"- Admin {index} : None\n"
        else :
            text += f"- Admin {index} : \n"
            text += f" - {proposition[0]} -> {to_hex(proposition[1])} \n"
    return text

# ----------------------------------------------------------------------

def on_off_to_bool(x):
    return True if x == "on" else False

def unexpected_argument(n, x) -> bool :
    if n != len(x) :
        eel.writeToConsole("Unexpected number of arguments.")
    return n != len(x)

def not_implemented() : eel.writeToConsole("Not implemented yet.")

@eel.expose
def query(text : str):
    print(f"Query : {text}")

    splitted = text.split()
    if len(splitted) == 0:
        return
    match splitted[0] :

        # -------------------------------------

        case "contract_declaration_address" :
            eel.writeToConsole(f"Contract Declaration Address :\n{globalState.DECLARED_ADDRESS}")            

        case "contract_address" :
            eel.writeToConsole(f"Contract Address :\n{globalState.DEPLOYED_ADDRESS}")
            
        case "fetch":
            eel.writeToConsole("Processing ..")
            # simulation_fetch(gen_classifier())
        case "auto_fetch":
            if unexpected_argument(2, splitted) : return
            globalState.auto_fetch = on_off_to_bool(splitted[1])
            if globalState.auto_fetch :
                eel.writeToConsole("Auto-Fetch: ENABLED")
                # simulation_mode()
            else :
                eel.writeToConsole("Auto-Fetch: DISABLE")

        case "resume" :
            pass

        # -------------------------------------

        case "clear": eel.clearConsole()
        case "help" : eel.writeToConsole(HELP)
        case "exit" : exit()
        case "" : pass
        case _ : eel.writeToConsole("invalid command")