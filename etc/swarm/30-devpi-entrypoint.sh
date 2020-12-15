#!/bin/bash

if [[ -z $FRONTEND_HOST ]]; then
    echo "Not exists FRONTEND_HOST env"
    exit 1
fi

if [[ -z $DEVPI_ROOT_PW ]]; then
    DEVPI_ROOT_PW_PATH=${DEVPI_ROOT_PW_PATH:-/run/secrets/devpi-root-pw}
    if [[ ! -f $DEVPI_ROOT_PW_PATH ]]; then
        echo "Not exists $DEVPI_ROOT_PW_PATH file, DEVPI_ROOT_PW env"
        exit 1
    fi
    DEVPI_ROOT_PW=`cat $DEVPI_ROOT_PW_PATH`
fi

SERVER_DATA_DIR=${SERVER_DATA_DIR:-/data}
if [[ ! -d "$SERVER_DATA_DIR" ]]; then
    mkdir -p "$SERVER_DATA_DIR"
fi

SERVER_VERSION_PATH=$SERVER_DATA_DIR/.serverversion
if [[ ! -f "$SERVER_VERSION_PATH" ]]; then
    devpi-init --serverdir "$SERVER_DATA_DIR" \
               --no-root-pypi \
               --root-passwd "$DEVPI_ROOT_PW"
fi

devpi-server --host 0.0.0.0 \
             --port 8080 \
             --restrict-modify root \
             --serverdir "$SERVER_DATA_DIR" \
             --outside-url "$FRONTEND_HOST"

