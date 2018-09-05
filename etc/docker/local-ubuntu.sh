#!/usr/bin/env bash

DOCKER_NAME=opm-ubuntu
EXISTS_DOCKER=`docker images | grep $DOCKER_NAME`
if [[ -z $EXISTS_DOCKER ]]; then
    docker build --tag=$DOCKER_NAME --file=local-ubuntu-dockerfile .
    CODE=$?
    if [[ $CODE -ne 0 ]]; then
        exit $CODE
    fi
fi

docker run -d -it -v $HOME/Public:/Public --name local-ubuntu $DOCKER_NAME /bin/bash

