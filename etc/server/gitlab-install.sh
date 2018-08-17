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

COMPOSE_YML=gitlab-compose.yml
if [[ ! -f "$COMPOSE_YML" ]]; then
    echo "Not found $COMPOSE_YML file"
    exit 1
fi

OPT_DIR=/opt/gitlab
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

CONFIG_TEMPLATE=gitlab-template.rb
CONFIG_PATH="$OPT_DIR/gitlab.rb"
if [[ -f "$CONFIG_PATH" ]]; then
    echo "Exists $CONFIG_PATH file"
else
    echo "Create $CONFIG_PATH file"
    cat "$CONFIG_TEMPLATE" | sed -e "s/@FRONTEND_HOST@/$FRONTEND_HOST/g" > "$CONFIG_PATH"
fi

STACK_NAME=gitlab
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Go to page $FRONTEND_HOST and continue setting."
echo "  Admin user name: root"
echo "Done ($?)."

