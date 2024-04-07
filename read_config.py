import json
import sys
import os

# get the path to up.sh directory
UP_SH_DIR = os.path.dirname(__file__)

# take argument from stdin
ARGUMENT_1 = sys.argv[1]

# read apps config
with open(f"{UP_SH_DIR}/apps.json", "r") as f:
    config = json.load(f)

APPS = config["apps"]


def find_app(ARGUMENT_1):
    for app_conf in APPS:
        if app_conf["name"] == ARGUMENT_1:
            return app_conf
    sys.stderr.write(f"App name '{ARGUMENT_1}' not found\n")
    sys.exit(1)


current_app = find_app(ARGUMENT_1)


with open(f"{UP_SH_DIR}/apps/.env_current", "w") as file:
    for key, value in current_app.items():
        if type(key) == str:
            file.write(f"export UPSH_APP_{key.upper()}={value}\n")
