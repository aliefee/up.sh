#!/bin/bash

# check if app name is given when running the script
if [ -z "$1" ]; then
    printf "Please provide an app name.\nExample: \e[1m\e[38;5;163m./up.sh \e[38;5;164mmyapp\e[0m\n"
    exit 1
fi

# "docker compose" or "podman-compose" or "nerdctl compose"
CONTAINER_CLI="docker compose"

# check if docker compose works
$CONTAINER_CLI version > /dev/null 2>&1
if [ $? -ne 0 ]; then
    CONTAINER_CLI="docker-compose"
    docker-compose version > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: docker compose or docker-compose is not installed."
        exit 1
    fi
fi

UPSH_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p $UPSH_PATH/apps
rm -f $UPSH_PATH/apps/.env_current

function clean_up_and_exit {
    rm -f $UPSH_PATH/apps/$UPSH_APP_NAME/*.sh
    rm -f $UPSH_PATH/apps/.env_current
    exit 1
}

python3 read_config.py $1
if [ $? -ne 0 ]; then
    clean_up_and_exit
fi

source apps/.env_current

# check if apps/$UPSH_APP_NAME exists
if [ ! -d $UPSH_PATH/apps/$UPSH_APP_NAME ]; then
    mkdir $UPSH_PATH/apps/$UPSH_APP_NAME
    if [ $? -ne 0 ]; then
        echo "Error: mkdir apps/$UPSH_APP_NAME failed"
        clean_up_and_exit
    fi
    echo "Created apps/$UPSH_APP_NAME."
fi

# check if $UPSH_APP_DIR exists and is not empty
if [ ! -d $UPSH_APP_DIR ]; then
    printf "\e[1m\e[38;5;36mapp directory does not exist! \e[38;5;35m$UPSH_APP_DIR\e[0m\n"
    clean_up_and_exit
elif [ -z "$(ls -A $UPSH_APP_DIR)" ]; then
    printf "\e[1m\e[38;5;36mWARNING \e[38;5;35mempty app directory $UPSH_APP_DIR\e[0m\n"
fi

# copy types
cp types/$UPSH_APP_TYPE/*.sh apps/$UPSH_APP_NAME

/bin/bash -c "cd $UPSH_PATH/apps/$UPSH_APP_NAME && ./create_compose_yml.sh"
if [ $? -ne 0 ]; then
    echo "Error: ./create_compose_yml.sh failed"
    clean_up_and_exit
fi

/bin/bash -c "cd $UPSH_PATH/apps/$UPSH_APP_NAME && ./create_dockerfile.sh"
if [ $? -ne 0 ]; then
    echo "Warning: ./create_dockerfile.sh failed"
fi

/bin/bash -c "cd $UPSH_PATH/apps/$UPSH_APP_NAME && $CONTAINER_CLI up -d"
if [ $? -ne 0 ]; then
    echo "Error: docker-compose up -d failed"
    clean_up_and_exit
fi

echo "Container "$UPSH_APP_TYPE"_"$UPSH_APP_NAME" is up and running."

while true; do
    printf "\e[1m\e[38;5;36mChoose:
    1- $CONTAINER_CLI down --volumes --rmi \"local\"
    2- $CONTAINER_CLI stop
    3- cd $UPSH_APP_DIR
    4- $CONTAINER_CLI exec app /bin/bash
    5- $CONTAINER_CLI exec -u 0 app /bin/bash$\e[0m\n
    6- Exit\n"
    
    read -n 1 -r -s

    if [[ $REPLY =~ ^[1]$ ]]; then
        /bin/bash -c "cd $UPSH_PATH/apps/$UPSH_APP_NAME && $CONTAINER_CLI down --volumes --rmi \"local\""
        clean_up_and_exit
    elif [[ $REPLY =~ ^[2]$ ]]; then
        /bin/bash -c "cd $UPSH_PATH/apps/$UPSH_APP_NAME && $CONTAINER_CLI stop"
        clean_up_and_exit
    elif [[ $REPLY =~ ^[3]$ ]]; then
        cd $UPSH_APP_DIR
        /bin/bash
    elif [[ $REPLY =~ ^[4]$ ]]; then
        /bin/bash -c "cd $UPSH_PATH/apps/$UPSH_APP_NAME && $CONTAINER_CLI exec app /bin/bash"
    elif [[ $REPLY =~ ^[5]$ ]]; then
        /bin/bash -c "cd $UPSH_PATH/apps/$UPSH_APP_NAME && $CONTAINER_CLI exec -u 0 app /bin/bash"
    elif [[ $REPLY =~ ^[6]$ ]]; then
        clean_up_and_exit
    fi
done
        
cd $UPSH_PATH

clean_up_and_exit
