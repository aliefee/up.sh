#!/bin/bash

# Type: python3-flask

######################
# Create compose.yml #
######################
printf "
services:
  app:
    build: .
    container_name: $UPSH_APP_TYPE-$UPSH_APP_NAME
    tty: true
    volumes:
      - $UPSH_APP_DIR:/home/$USER/$UPSH_APP_NAME
" > compose.yml

if [ -n "$UPSH_APP_PORT" ]; then

printf "
    ports: 
      - \"$UPSH_APP_PORT:$UPSH_APP_PORT\"
" >> compose.yml

fi




