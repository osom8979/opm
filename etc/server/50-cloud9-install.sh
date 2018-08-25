#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

export PUBLISH_PORT=$1
export CLOUD9_USER=${2:-admin}
export CLOUD9_PASS=${3:-admin}
export DOCKER_PATH=`which docker`

if [[ -z $PUBLISH_PORT ]]; then
    echo "Usage: $0 {port} {user:admin} {pw:admin}"
    exit 1
fi

OPT_DIR=/opt/opm/cloud9
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

STACK_NAME=cloud9
COMPOSE_YML=50-cloud9-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Web url: http://localhost:$PUBLISH_PORT"
echo "  Username: $CLOUD9_USER"
echo "  Password: $CLOUD9_PASS"
echo "Done ($CODE)."

