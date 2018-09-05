#!/usr/bin/env bash

PUBLISH_PORT=$1
if [[ -z $PUBLISH_PORT ]]; then
    echo "Usage: $0 {publish_port}"
    exit 1
fi

export PUBLISH_PORT
echo "Publish Port: $PUBLISH_PORT"

STACK_NAME=gitlab_8_11_7
COMPOSE_YML=gitlab-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Go to page http://localhost:$PUBLISH_PORT and continue setting."
echo "  Admin user name: root"
echo "  Admin password: 5iveL!fe"
echo "Information:"
echo "  Entry point: /sbin/entrypoint.sh"
echo "  Backup command: app:rake gitlab:backup:create"
echo "  Restore command: app:rake gitlab:backup:restore"
echo "See also: https://github.com/Georce/gitlab/blob/master/8.11.7.md"
echo "Done ($CODE)."

