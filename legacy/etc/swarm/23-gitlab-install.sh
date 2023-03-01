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

OPT_DIR=/opt/opm/gitlab
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

CONFIG_TEMPLATE=23-gitlab-template.rb
CONFIG_PATH="$OPT_DIR/gitlab.rb"
if [[ -f "$CONFIG_PATH" ]]; then
    echo "Exists $CONFIG_PATH file"
else
    echo "Create $CONFIG_PATH file"
    cat "$CONFIG_TEMPLATE" | sed -e "s/@FRONTEND_HOST@/$FRONTEND_HOST/g" > "$CONFIG_PATH"
fi

STACK_NAME=gitlab
COMPOSE_YML=23-gitlab-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Go to page $FRONTEND_HOST and continue setting."
echo "  Admin user name: root"
echo "Done ($CODE)."

