import json
import sys
import os

# get the path to up.sh directory
UP_SH_DIR = os.path.dirname(__file__)

# take argument from stdin
ARGUMENT_1 = sys.argv[1]


def validate_app_config(config):
    if "apps" not in config:
        sys.stderr.write("Apps not found in apps.json\n")
        sys.exit(1)
    apps = config["apps"]
    for app in apps:
        if "dir" not in app:
            sys.stderr.write("App dir not found in apps.json\n")
            sys.exit(1)
        if "name" not in app:
            sys.stderr.write("App name not found in apps.json\n")
            sys.exit(1)
    return apps


def find_app(app_name):
    for app in APPS:
        if app["name"] == app_name:
            return app
    sys.stderr.write(f"App name '{app_name}' not found\n")
    sys.exit(1)


# read apps config
with open(f"{UP_SH_DIR}/apps.json", "r") as f:
    config = json.load(f)

APPS = validate_app_config(config)

current_app = find_app(ARGUMENT_1)

with open(f"{UP_SH_DIR}/apps/.env_current", "w") as file:
    for key, value in current_app.items():
        if type(key) == str:
            file.write(f"export UPSH_APP_{key.upper()}={value}\n")
