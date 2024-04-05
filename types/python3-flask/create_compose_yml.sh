#!/bin/bash

# Type: python3-flask

######################
# Create compose.yml #
######################
printf "
services:
  app:
    build: .
    container_name: $APP_TYPE-$APP_NAME
    tty: true
    volumes:
      - ./src:/home/$USER/$APP_NAME
" > compose.yml

if [ -n "$APP_PORT" ]; then

printf "
    ports: 
      - \"$APP_PORT:$APP_PORT\"
" >> compose.yml

fi




