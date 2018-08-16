#!/usr/bin/env bash

COMPOSE_YML=test-compose.yml
if [[ ! -f "$COMPOSE_YML" ]]; then
    echo "Not found $COMPOSE_YML file"
    exit 1
fi

FRONTEND_HOST=$1
if [[ -z $FRONTEND_HOST ]]; then
    echo "Usage: $0 {FRONTEND_HOST}"
    exit 1
fi

export FRONTEND_HOST
echo "Frontend Host: $FRONTEND_HOST"

STACK_NAME=test
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Done ($?)."

