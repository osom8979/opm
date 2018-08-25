#!/usr/bin/env bash

FRONTEND_HOST=$1
if [[ -z $FRONTEND_HOST ]]; then
    echo "Usage: $0 {frontend_host}"
    exit 1
fi

export FRONTEND_HOST
echo "Frontend Host: $FRONTEND_HOST"

COMPOSE_YML=rocket-compose.yml
if [[ ! -f "$COMPOSE_YML" ]]; then
    echo "Not found $COMPOSE_YML file"
    exit 1
fi

STACK_NAME=rocket
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Done ($?)."

