#!/usr/bin/env bash

WORKSPACE=$1
PUBLISH_PORT=${2:-9999}
CLOUD9_USER=${3:-admin}
CLOUD9_PASS=${4:-admin}
DOCKER_PATH=`which docker`

if [[ -z $WORKSPACE ]]; then
    echo "Usage: $0 {workspace} {port:9999} {user:admin} {pw:admin}"
    exit 1
fi

if [[ -d "$WORKSPACE" ]]; then
    echo "Exists $WORKSPACE directory"
else
    echo "Create $WORKSPACE directory"
    mkdir -p "$WORKSPACE"
fi

echo "Workspace: $WORKSPACE"
echo "User: $CLOUD9_USER"
echo "Password: $CLOUD9_PASS"
echo "Port: $PUBLISH_PORT"

docker run -d \
    -v $WORKSPACE:/workspace \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $DOCKER_PATH:/bin/docker \
    -p $PUBLISH_PORT:8080 \
    damnhandy/cloud9-sdk \
    --listen "0.0.0.0" -p "8080" -w "/workspace" -a "${CLOUD9_USER}:${CLOUD9_PASS}"

echo "Done ($?)."

