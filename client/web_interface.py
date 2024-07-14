import eel
import time
from threading import Thread
from common import globalState
from simulation_data import sample
# from basic_model_sample import
from contract import invoke_predict

# ----------------------------------------------------------------------

HELP = '''
Commands :
    - help / clear / exit
    
    - fetch
    - predict
        - requires to fetch before

    - auto_fetch on/off (default: off)
    - auto_commit on/off (default: off, ie. fetch => commit)
    - auto_resume on/off (default: off, ie. commit => resume)

    - get_filtered_epoch
    - get_propositions

    - evaluate_stored_prediction

    - get_validator_list
    - get_countries_list
    - get_countrie_scores
    
    # Validator replacement
    - update_proposition
    - vote_for_a_proposition
    - get_replacement_propositions
    - get_a_specific_proposition

    - contract_declaration_address
    - contract_address


For <validator> <bot> arguments, you can either specify the index in the contract or the address starting with "0x"

(S) indicates an interaction with Sepolia

---------------------------------------

'''

# ----------------------------------------------------------------------

def init_server():
    print("Starting graphical interface...")
    eel.init('web')
    eel.start('index.html',
            mode='default',
            host='localhost',
            block=False)

# ----------------------------------------------------------------------

# TODO:
def propositions_as_str(only_not_none = False) -> str:
    propositions = None #call_replacement_propositions()
    text = ""
    for index, proposition in enumerate(propositions) :
        if proposition is None :
            if not only_not_none:
                text += f"- Validator {index} : None\n"
        else :
            text += f"- Validator {index} : \n"
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
            X, Y = sample()
            globalState.current_sample = X
            model_Y = None
            visual = f"X = \n{X}\n Expected Y = \n{Y}\nExpected model\nY = \n{model_Y}"
            eel.setSimulationConsole(
                visual
            )

        case "predict":
            eel.writeToConsole("Processing ..")
            invoke_predict(globalState.current_sample)


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