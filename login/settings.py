import platform

PASSFILE      = "passfile"
HOME_DIR      = ""
DEFAULT_SHELL = ""
DEFAULT_ROOT  = ""

if platform.system() == "Windows":
    print("windows warning: this was built on linux, with windows support as an afterthought!")
    print("windows warning: this uses unix newlines (\\n)")
    print("windows warning: you have been warned!")

    HOME_DIR      = "C:\\Users\\"
    DEFAULT_SHELL = "C:\\Windows\\System32\\cmd.exe"
    DEFAULT_ROOT  = "C:\\"
else:
    HOME_DIR      = "/home/"
    DEFAULT_SHELL = "/bin/sh"
    DEFAULT_ROOT  = "/"
