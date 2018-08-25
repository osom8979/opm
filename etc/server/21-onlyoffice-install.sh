#!/usr/bin/env bash 

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

DEFAULT_SECRET_KEY=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

FRONTEND_HOST=$1
SECRET_KEY=${2:-${DEFAULT_SECRET_KEY}}
if [[ -z $FRONTEND_HOST ]]; then
    echo "Usage: $0 {frontend_host} {secret_key:'random'}"
    exit 1
fi

export FRONTEND_HOST
echo "Frontend Host: $FRONTEND_HOST"
echo "Secret Key: $SECRET_KEY"

OPT_DIR=/opt/opm/onlyoffice
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

DEFAULT_TEMPLATE=21-onlyoffice-default.json
DEFAULT_SCRIPT_PATH=$OPT_DIR/default.json
if [[ -f "$DEFAULT_SCRIPT_PATH" ]]; then
    echo "Exists $DEFAULT_SCRIPT_PATH file"
else
    echo "Create $DEFAULT_SCRIPT_PATH file"
    cat "$DEFAULT_TEMPLATE" | sed -e "s/@SECRET_KEY@/$SECRET_KEY/g" > "$DEFAULT_SCRIPT_PATH"
fi

STACK_NAME=onlyoffice
COMPOSE_YML=21-onlyoffice-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Document server host: https://${STACK_NAME}_api"
echo "Done ($CODE)."

