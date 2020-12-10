#!/usr/bin/env bash

FRONTEND_HOST=$1
BACKEND_HOST=$2
if [[ -z $FRONTEND_HOST || -z $BACKEND_HOST ]]; then
    echo "Usage: $0 {frontend_host} {backend_host}"
    exit 1
fi

export FRONTEND_HOST
echo "Frontend Host: $FRONTEND_HOST"
echo "Backend Host: $BACKEND_HOST"

OPT_DIR=/opt/opm/nginx-forward
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

DEFAULT_CONFIG_TEMPLATE=51-nginx-forward.conf
DEFAULT_CONFIG_PATH="$OPT_DIR/$FRONTEND_HOST.conf"
if [[ -f "$DEFAULT_CONFIG_PATH" ]]; then
    echo "Exists $DEFAULT_CONFIG_PATH file"
else
    echo "Create $DEFAULT_CONFIG_PATH file"

    cat "$DEFAULT_CONFIG_TEMPLATE" | sed \
        -e "s/@FRONTEND_HOST@/$FRONTEND_HOST/g" \
        -e "s/@BACKEND_HOST@/$BACKEND_HOST/g" \
        > "$DEFAULT_CONFIG_PATH"
fi

STACK_NAME=nginx-forward-$FRONTEND_HOST
COMPOSE_YML=51-nginx-forward.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Create Forward-proxy server: Public(${FRONTEND_HOST}) -> Private(${BACKEND_HOST})"
echo "Done ($CODE)."

