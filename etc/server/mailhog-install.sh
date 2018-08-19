#!/usr/bin/env bash

NET_NAME=mailhog-net
NET_EXISTS=`docker network ls | grep $NET_NAME`
if [[ -z $NET_EXISTS ]]; then
    echo "Create $NET_NAME overlay network"
    docker network create -d overlay "$NET_NAME"
else
    echo "Exists $NET_NAME"
fi

STACK_NAME=mailhog
COMPOSE_YML=mailhog-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "MailHog web: http://localhost:10002/"
echo "  Local MailHog network: $NET_NAME"
echo "  Local MailHog SMTP: ${STACK_NAME}_api:1025"
echo "  Local MailHog HTTP: ${STACK_NAME}_api:8025"
echo "Done ($?)."

