#!/usr/bin/env bash

IMAGE_NAME=devpi:python37
IMAGE_EXISTS=`docker images --format '{{.Repository}}:{{.Tag}}' | grep "^${IMAGE_NAME}\$"`
if [[ -z $IMAGE_EXISTS ]]; then
    echo "Not found docker image: $IMAGE_NAME"
    exit 1
fi

FRONTEND_HOST=$1
if [[ -z $FRONTEND_HOST]]; then
    echo "Usage: $0 {frontend_host}"
    exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

OPT_DIR=/opt/opm/devpi
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

export FRONTEND_HOST
export OPT_DIR
echo "Frontend Host: $FRONTEND_HOST"
echo "Server data directory: $OPT_DIR"

SECRET_NAME=devpi-root-pw
SECRET_EXISTS=`docker secret ls | grep $SECRET_NAME`
if [[ -z $SECRET_EXISTS ]]; then
    read -sp "Enter the docker-secret ($SECRET_NAME) password: " SECRET_VALUE
    echo -e "\nCreate $SECRET_NAME secret"
    echo "$SECRET_VALUE" | docker secret create "$SECRET_NAME" -
else
    echo "Exists $SECRET_NAME"
fi

STACK_SUFFIX=`echo $FRONTEND_HOST | sed -e 's/[.]/-/g'`
STACK_NAME=devpi
COMPOSE_YML=30-devpi-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Create devpi server: ${FRONTEND_HOST}"
echo "Stack name: $STACK_NAME"
echo "Done ($CODE)."

