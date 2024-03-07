import settings
import functions

def helpMessage(userList):
    print("list of commands:")
    print("\t?: display this message")
    print("\tl: list existing users")
    print("\ta: append a new user")
    print("\td: delete an existing user")
    print("\tn: change the name of an existing user")
    print("\tp: change the password of an existing user")
    print("\th: change the home of an existing user")
    print("\tc: change the command of an existing user")
    print(f"\tw: write to {settings.PASSFILE} without exit")
    print("\tq: quit/exit\n")

    print("\texample:\n")
    print("\t0 useredit> a")
    print("\tname: new user")
    print("\tpassword: 1337_pAsS")
    print(f"\thome (leave blank for {settings.HOME_DIR}new user): {settings.HOME_DIR}new_user")
    print(f"\tcommand (leave blank for {settings.DEFAULT_SHELL}):\n")

    return 0, userList

def listUsers(userList):
    for user in userList:
        name    = user["name"]
        hash    = user["hash"]
        home    = user["home"]
        command = user["command"]

        print(name)
        print(f"\tname:    {name}")
        print(f"\thash:    {hash}")
        print(f"\thome:    {home}")
        print(f"\tcommand: {command}")

    return 0, userList

def appendUser(userList):
    existingUsers = functions.existingUsers(userList)
    name          = None
    password      = None
    home          = None
    command       = None

    print("user: ", end="")
    name = input()

    if name in existingUsers:
        print("user already exists")

        return 1, userList

    print("password: ", end="")
    password = input()

    print(f"home: (leave blank for {settings.HOME_DIR}{name}): ", end="")
    home = input()

    print(f"command (leave blank for {settings.DEFAULT_SHELL}): ", end="")
    command = input()

    if home == "":
        home = settings.HOME_DIR + name

    if command == "":
        command = settings.DEFAULT_SHELL

    userList.append({
        "name":    name,
        "hash":    functions.djb2(password),
        "home":    home,
        "command": command
    })

    return 0, userList

def deleteUser(userList):
    existingUsers = functions.existingUsers(userList)
    name          = None

    print("user: ", end="")
    name = input()

    if not name in existingUsers:
        print("user does not exist")

        return 1, userList

    del userList[existingUsers[name]]
    
    return 0, userList

def changeName(userList):
    existingUsers = functions.existingUsers(userList)
    name          = None
    newName       = None

    print("user: ", end="")
    name = input()

    if not name in existingUsers:
        print("user does not exist")

        return 1, userList

    print("new name: ", end="")
    newName = input()

    userList[existingUsers[name]]["name"] = newName

    return 0, userList

def changePassword(userList):
    existingUsers = functions.existingUsers(userList)
    name          = None
    newPassword   = None

    print("user: ", end="")
    name = input()

    if not name in existingUsers:
        print("user does not exist")

        return 1, userList

    print("new password: ", end="")
    newPassword = input()

    userList[existingUsers[name]]["hash"] = functions.djb2(newPassword)

    return 0, userList

def changeHome(userList):
    existingUsers = functions.existingUsers(userList)
    name          = None
    newHome       = None

    print("user: ", end="")
    name = input()

    if not name in existingUsers:
        print("user does not exist")

        return 1, userList

    print("new home: ", end="")
    newHome = input()

    userList[existingUsers[name]]["home"] = newHome

    return 0, userList

def changeCommand(userList):
    existingUsers = functions.existingUsers(userList)
    name          = None
    newCommand    = None

    print("user: ", end="")
    name = input()

    if not name in existingUsers:
        print("user does not exist")

        return 1, userList

    print("new command: ", end="")
    newCommand = input()

    userList[existingUsers[name]]["command"] = newCommand

    return 0, userList

def writePassfile(userList):
    functions.writePassfile(settings.PASSFILE, userList)

    return 0, userList

def runCommand(command, userList):
    commands = {
        "?": helpMessage,
        "l": listUsers,
        "a": appendUser,
        "d": deleteUser,
        "n": changeName,
        "p": changePassword,
        "h": changeHome,
        "c": changeCommand,
        "w": writePassfile
    }

    if command in commands:
        return commands[command](userList)

    return 127, userList

def editShell():
    print("run `?' for a list of commands")

    command  = None
    userList = functions.readPassfile(settings.PASSFILE)
    status   = 0

    while True:
        print(str(status) + " useredit> ", end="")
        command = input()

        if (command == "q"):
            break

        status, userList = runCommand(command, userList)

        if status == 127:
            print(command + ": no such command")

    functions.writePassfile(settings.PASSFILE, userList)

editShell()
