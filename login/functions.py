import re

import settings

def djb2(string):
    hash = 5381

    for a in range(len(string)):
        hash = ((hash << 5) + hash) + ord(string[a])

    return hash

def readPassfile(fileName):
    passfile = None
    userList = []

    try:
        passfile = open(fileName, "r")
    except:
        return []

    lines = passfile.readlines()

    for line in lines:
        line = line.replace("\n", "")
        line = re.split(r"(?<!\\):", line)

        if len(line) < 4:
            continue

        if line[1].isnumeric():
            line[1] = int(line[1])
        else:
            continue

        userList.append({
            "name":    line[0].replace("\\:", ":"),
            "hash":    line[1],
            "home":    line[2].replace("\\:", ":"),
            "command": line[3].replace("\\:", ":")
        })

    passfile.close()

    return userList

def writePassfile(fileName, userList):
    passfile = open(fileName, "w+")

    for user in userList:
        name    = user["name"].replace(":", "\\:")
        hash    = user["hash"]
        home    = user["home"].replace(":", "\\:")
        command = user["command"].replace(":", "\\:")

        passfile.write(f"{name}:{hash}:{home}:{command}\n")

    passfile.close()

def existingUsers(userList):
    existingUsers = {}

    for userIndex in range(len(userList)):
        existingUsers[userList[userIndex]["name"]] = userIndex

    return existingUsers

def login(userList):
    name     = None
    password = None

    print("login: ", end="")

    name = input()

    print("password: ", end="")

    password = input()

    for user in userList:
        if name != user["name"]:
            continue

        if djb2(password) == user["hash"]:
            return user

    return None
