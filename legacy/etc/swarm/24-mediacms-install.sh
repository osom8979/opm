#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

FRONTEND_HOST=$1
ADMIN_EMAIL=$2
if [[ -z $FRONTEND_HOST || -z $ADMIN_EMAIL ]]; then
    echo "Usage: $0 {frontend_host} {admin_email}"
    exit 1
fi

export FRONTEND_HOST
export ADMIN_EMAIL
echo "Frontend Host: $FRONTEND_HOST"
echo "Admin Email: $ADMIN_EMAIL"

OPT_DIR=/opt/opm/mediacms
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

SECRET_NAME=mediacms-db-pw
SECRET_EXISTS=`docker secret ls | grep $SECRET_NAME`
if [[ -z $SECRET_EXISTS ]]; then
    read -sp "Enter the docker-secret ($SECRET_NAME) password: " SECRET_VALUE
    echo -e "\nCreate $SECRET_NAME secret"
    echo "$SECRET_VALUE" | docker secret create "$SECRET_NAME" -
else
    echo "Exists $SECRET_NAME"
fi

CONFIG_TEMPLATE=24-mediacms-local-settings.py
CONFIG_PATH="$OPT_DIR/local_settings.py"
if [[ -f "$CONFIG_PATH" ]]; then
    echo "Exists $CONFIG_PATH file"
else
    echo "Create $CONFIG_PATH file"
    cat "$CONFIG_TEMPLATE" | sed \
        -e "s/@FRONTEND_HOST@/$FRONTEND_HOST/g" \
        -e "s/@ADMIN_EMAIL@/$ADMIN_EMAIL/g" \
        > "$CONFIG_PATH"
fi

STACK_NAME=mediacms
COMPOSE_YML=24-mediacms-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Go to page $FRONTEND_HOST and continue setting."
echo "Done ($CODE)."

