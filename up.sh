#!/bin/bash

# "docker compose" or "podman-compose" or "nerdctl compose"
CONTAINER_CLI="docker compose"

# check if docker compose works
docker compose version > /dev/null 2>&1
if [ $? -ne 0 ]; then
    CONTAINER_CLI="docker-compose"
    docker-compose version > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: docker compose or docker-compose is not installed."
        exit 1
    fi
fi

UP_SH_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# check if app name is given when running the script
if [ -z "$1" ]; then
    printf "Please provide an app name.\nExample: \e[1m\e[38;5;163m./up.sh \e[38;5;164mmyapp\e[0m\n"
    exit 1
fi

mkdir -p apps
rm -f apps/.env_current

function clean_up_and_exit {
    rm -f apps/$APP_NAME/*.sh
    #rm -f apps/.env_current
    exit 1
}

python3 read_config.py $1
if [ $? -ne 0 ]; then
    clean_up_and_exit
fi

source apps/.env_current

# check if apps/$APP_NAME exists
if [ ! -d apps/$APP_NAME ]; then
    mkdir apps/$APP_NAME
    if [ $? -ne 0 ]; then
        echo "Error: mkdir apps/$APP_NAME failed"
        clean_up_and_exit
    fi
    echo "Created directory apps/$APP_NAME."
fi

# check if apps/$APP_NAME exists and is not empty
if [ ! -d apps/$APP_NAME/src ]; then
    mkdir apps/$APP_NAME/src
    if [ $? -ne 0 ]; then
        echo "Error: mkdir apps/$APP_NAME/src failed"
        clean_up_and_exit
    fi
    echo "Created directory apps/$APP_NAME/src."
    printf "\e[1m\e[38;5;36mNow it is time to put your $APP_TYPE app files in:
\e[38;5;35m $(pwd)/apps/$APP_NAME/src \e[0m\n"
    clean_up_and_exit
elif [ -z "$(ls -A apps/$APP_NAME/src)" ]; then
    echo " src folder is empty."
    printf "\e[1m\e[38;5;36mPlease put your $APP_TYPE app files in:
\e[38;5;35m $(pwd)/apps/$APP_NAME/src \e[0m\n"
    clean_up_and_exit
fi

# copy types
cp types/$APP_TYPE/* apps/$APP_NAME

/bin/bash -c "cd $UP_SH_PATH/apps/$APP_NAME && ./create_compose_yml.sh"
if [ $? -ne 0 ]; then
    echo "Error: ./create_compose_yml.sh failed"
    clean_up_and_exit
fi

/bin/bash -c "cd $UP_SH_PATH/apps/$APP_NAME && ./create_dockerfile.sh"
if [ $? -ne 0 ]; then
    echo "Error: ./create_dockerfile.sh failed"
    clean_up_and_exit
fi

/bin/bash -c "cd $UP_SH_PATH/apps/$APP_NAME && $CONTAINER_CLI up -d"
if [ $? -ne 0 ]; then
    echo "Error: docker-compose up -d failed"
    clean_up_and_exit
fi

echo "Container "$APP_TYPE"_"$APP_NAME" is up and running."

while true; do
    printf "\e[1m\e[38;5;36mChoose:
    1- $CONTAINER_CLI down
    2- $CONTAINER_CLI stop
    3- cd ./apps/$APP_NAME/src
    4- $CONTAINER_CLI exec app /bin/bash
    5- $CONTAINER_CLI exec -u 0 app /bin/bash$\e[0m\n
    6- Exit\n"
    
    read -n 1 -r -s

    if [[ $REPLY =~ ^[1]$ ]]; then
        /bin/bash -c "cd $UP_SH_PATH/apps/$APP_NAME && $CONTAINER_CLI down"
        clean_up_and_exit
    elif [[ $REPLY =~ ^[2]$ ]]; then
        /bin/bash -c "cd $UP_SH_PATH/apps/$APP_NAME && $CONTAINER_CLI stop"
        clean_up_and_exit
    elif [[ $REPLY =~ ^[3]$ ]]; then
        cd $UP_SH_PATH/apps/$APP_NAME/src
        /bin/bash
    elif [[ $REPLY =~ ^[4]$ ]]; then
        /bin/bash -c "cd $UP_SH_PATH/apps/$APP_NAME && $CONTAINER_CLI exec app /bin/bash"
    elif [[ $REPLY =~ ^[5]$ ]]; then
        /bin/bash -c "cd $UP_SH_PATH/apps/$APP_NAME && $CONTAINER_CLI exec -u 0 app /bin/bash"
    elif [[ $REPLY =~ ^[6]$ ]]; then
        clean_up_and_exit
    fi
done
        
cd $UP_SH_PATH

clean_up_and_exit
