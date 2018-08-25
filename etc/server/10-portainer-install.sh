#!/usr/bin/env bash

PUBLISH_PORT=${1-10010}
if [[ -z $PUBLISH_PORT ]]; then
    echo "Usage: $0 {publish_port:10010}"
    exit 1
fi

export PUBLISH_PORT
echo "Publish Port: $PUBLISH_PORT"

STACK_NAME=portainer
COMPOSE_YML=10-portainer-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Portainer web: http://localhost:$PUBLISH_PORT/"
echo "Done ($CODE)."

