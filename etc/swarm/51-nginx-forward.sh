#!/usr/bin/env bash

FRONTEND_HOST=$1   # e.g. test.site.com
BACKEND_PREFIX=$2  # e.g. https://192.168.0.2:8080
if [[ -z $FRONTEND_HOST || -z $BACKEND_PREFIX ]]; then
    echo "Usage: $0 {frontend_host} {backend_host}"
    exit 1
fi

export FRONTEND_HOST
export BACKEND_PREFIX
echo "Frontend Host: $FRONTEND_HOST"
echo "Backend Host: $BACKEND_PREFIX"

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

OPT_DIR=/opt/opm/nginx-forward
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

DEFAULT_CONFIG_TEMPLATE=51-nginx-forward.conf
DEFAULT_CONFIG_PATH="$OPT_DIR/$FRONTEND_HOST.conf"
export DEFAULT_CONFIG_PATH
if [[ -f "$DEFAULT_CONFIG_PATH" ]]; then
    echo "Exists $DEFAULT_CONFIG_PATH file"
else
    echo "Create $DEFAULT_CONFIG_PATH file"

    cat "$DEFAULT_CONFIG_TEMPLATE" | sed \
        -e "s/@FRONTEND_HOST@/$FRONTEND_HOST/g" \
        -e "s/@BACKEND_PREFIX@/$BACKEND_PREFIX/g" \
        > "$DEFAULT_CONFIG_PATH"
fi

STACK_SUFFIX=`echo $FRONTEND_HOST | sed -e 's/[.]/-/g'`
STACK_NAME=nginx-forward-$STACK_SUFFIX
COMPOSE_YML=51-nginx-forward.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Create Forward-proxy server: Public(${FRONTEND_HOST}) -> Private(${BACKEND_PREFIX})"
echo "Stack name: $STACK_NAME"
echo "Done ($CODE)."

