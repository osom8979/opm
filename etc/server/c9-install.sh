#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

OPT_DIR=/opt/c9
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

WORKSPACE_DIR=$OPT_DIR/workspace
if [[ -d "$WORKSPACE_DIR" ]]; then
    echo "Exists $WORKSPACE_DIR directory"
else
    echo "Create $WORKSPACE_DIR directory"
    mkdir -p "$WORKSPACE_DIR"
fi

export PUBLISH_PORT=$1
export CLOUD9_USER=${2:-admin}
export CLOUD9_PASS=${3:-admin}
export DOCKER_PATH=`which docker`

if [[ -z $PUBLISH_PORT ]]; then
    echo "Usage: $0 {port} {user:admin} {pw:admin}"
    exit 1
fi

echo "User: $CLOUD9_USER"
echo "Password: $CLOUD9_PASS"
echo "Port: $PUBLISH_PORT"

COMPOSE_YML=c9-compose.yml
if [[ ! -f "$COMPOSE_YML" ]]; then
    echo "Not found $COMPOSE_YML file"
    exit 1
fi

STACK_NAME=c9
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Done ($?)."

