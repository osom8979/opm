#!/usr/bin/env bash

FRONTEND_HOST=$1
if [[ -z $FRONTEND_HOST ]]; then
    echo "Usage: $0 {frontend_host}"
    exit 1
fi

export FRONTEND_HOST
echo "Frontend Host: $FRONTEND_HOST"

read -p "Enter the database ID: " DB_ID
export DB_ID

read -p "Enter the database PW: " DB_PW
export DB_PW

STACK_NAME=nocodb
COMPOSE_YML=26-nocodb-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "NocoDB web: ${FRONTEND_HOST}"
echo "Done ($CODE)."

