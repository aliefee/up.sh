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

COPY ./src/requirements.txt /tmp

RUN pip3 install -r /tmp/requirements.txt

WORKDIR /home/$USER/$APP_NAME

EXPOSE $APP_PORT

ENTRYPOINT [\"python3\", \"-m\", \"flask\", \"run\", \"--host=0.0.0.0\", \"--port=$APP_PORT\", \"--debug\"]
" > Dockerfile
