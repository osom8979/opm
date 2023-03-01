#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

FRONTEND_HOST=$1
if [[ -z $FRONTEND_HOST ]]; then
    echo "Usage: $0 {frontend_host}"
    exit 1
fi

export FRONTEND_HOST
echo "Frontend Host: $FRONTEND_HOST"

OPT_DIR=/opt/opm/streama
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

SECRET_NAME=streama-db-pw
SECRET_EXISTS=`docker secret ls | grep $SECRET_NAME`
if [[ -z $SECRET_EXISTS ]]; then
    read -sp "Enter the docker-secret ($SECRET_NAME) password: " SECRET_VALUE
    echo -e "\nCreate $SECRET_NAME secret"
    echo "$SECRET_VALUE" | docker secret create "$SECRET_NAME" -
else
    echo "Exists $SECRET_NAME"
fi

CONFIG_TEMPLATE=25-streama-application.yml
CONFIG_PATH="$OPT_DIR/application.yml"
if [[ -f "$CONFIG_PATH" ]]; then
    echo "Exists $CONFIG_PATH file"
else
    echo "Create $CONFIG_PATH file"
    cat "$CONFIG_TEMPLATE" | sed \
        -e "s/@FRONTEND_HOST@/$FRONTEND_HOST/g" \
        -e "s/@DATABASE_PASSWORD@/$SECRET_VALUE/g" \
        > "$CONFIG_PATH"
fi

STACK_NAME=streama
COMPOSE_YML=25-streama-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Go to page $FRONTEND_HOST and continue setting."
echo "Done ($CODE)."

