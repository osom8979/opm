#!/usr/bin/env bash

FRONTEND_HOST=$1
DOCKER_FRONTEND_HOST=$2
if [[ -z $FRONTEND_HOST || -z $DOCKER_FRONTEND_HOST ]]; then
    echo "Usage: $0 {frontend_host} {docker_frontend_host}"
    exit 1
fi

export FRONTEND_HOST
export DOCKER_FRONTEND_HOST
echo "Frontend host: $FRONTEND_HOST"
echo "Docker frontend host: $DOCKER_FRONTEND_HOST"

STACK_NAME=nexus
COMPOSE_YML=nexus-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Done ($?)."

