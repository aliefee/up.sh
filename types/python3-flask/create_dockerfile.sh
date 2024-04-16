#!/bin/bash

# Type: python3-flask

#####################
# Create Dockerfile #
#####################
printf "
FROM python:3-slim-bookworm

SHELL [\"/bin/bash\", \"-c\"]

RUN useradd --uid $UID --password \"\" --shell /bin/bash --create-home --user-group  $USER

USER $USER

RUN python3 -m venv /home/$USER/venv

ENV VIRTUAL_ENV=/home/$USER/venv

ENV PATH=\"\$VIRTUAL_ENV/bin:\$PATH\"
" > Dockerfile



if [ -f $UPSH_APP_DIR/requirements.txt ]; then
cp $UPSH_APP_DIR/requirements.txt ./requirements.txt

printf "
COPY ./requirements.txt /tmp

RUN pip3 install -r /tmp/requirements.txt
" >> Dockerfile
fi

printf "
WORKDIR /home/$USER/$UPSH_APP_NAME

EXPOSE $UPSH_APP_PORT

ENTRYPOINT [\"python3\", \"-m\", \"flask\", \"run\", \"--host=0.0.0.0\", \"--port=$UPSH_APP_PORT\", \"--debug\"]
" >> Dockerfile
