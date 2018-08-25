#!/usr/bin/env bash

WEB_PORT=$1
EXT_PORT=${2:-15000}
if [[ -z $WEB_PORT || -z $EXT_PORT ]]; then
    echo "Usage: $0 {web_port} {ext_port:15000}"
    exit 1
fi

export WEB_PORT
export EXT_PORT
echo "Web port: $WEB_PORT"
echo "Ext port: $EXT_PORT"

STACK_NAME=nexus
COMPOSE_YML=30-nexus-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Web url: http://localhost:$WEB_PORT"
echo "  Username: admin"
echo "  Password: admin123"
echo "Done ($CODE)."

