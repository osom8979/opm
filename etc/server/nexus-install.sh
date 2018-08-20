#!/usr/bin/env bash

STACK_NAME=nexus
COMPOSE_YML=nexus-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Done ($?)."

