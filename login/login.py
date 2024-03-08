import os
import time
import subprocess

import settings
import functions

def loginShell():
    userList = functions.readPassfile(settings.PASSFILE)

    name     = None
    password = None
    user     = None
    command  = None
    home     = None

    while True:
        user = functions.login(userList)

        if user:
            break

        time.sleep(3)
        print("login failure\n")

    command = user["command"]
    home    = user["home"]

    if not os.path.exists(command):
        print(f"{command}: no such file or directory")

        command = settings.DEFAULT_SHELL

    if not os.path.exists(home):
        print(f"{home}: no such file or directory")

        home = settings.DEFAULT_ROOT

    subprocess.run(command, cwd=home)

loginShell()
