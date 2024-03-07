import time
import subprocess

import settings
import functions

def loginShell():
    userList = functions.readPassfile(settings.PASSFILE)

    name     = None
    password = None
    user     = None

    while True:
        user = functions.login(userList)

        if user:
            break

        time.sleep(3)
        print("login failure\n")

    subprocess.run(user["command"], cwd=user["home"])

loginShell()
