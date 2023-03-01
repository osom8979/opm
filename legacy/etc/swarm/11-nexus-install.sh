#!/usr/bin/env bash

DOCKER_IMAGE_NAME=nexus-repository-apt
DOCKER_IMAGE_TAG=3.11.0
export DOCKER_IMAGE_NAME
export DOCKER_IMAGE_TAG

EXISTS_DOCKER_IMAGE=`docker images --all | grep $DOCKER_IMAGE_NAME`
if [[ -z $EXISTS_DOCKER_IMAGE ]]; then
    SRC="https://github.com/sonatype-nexus-community/nexus-repository-apt"
    DEST=nexus-repository-apt
    pushd $PWD
    if [[ -d "$DEST/.git" ]]; then
        cd $DEST
        git pull
    else
        git clone --depth 1 "$SRC" "$DEST"
        cd $DEST
    fi

    docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG .
    DOCKER_BUILD_CODE=$?
    if [[ ! $DOCKER_BUILD_CODE -eq 0 ]]; then
        echo "Docker build error ($DOCKER_BUILD_CODE)."
        exit $DOCKER_BUILD_CODE
    fi
    popd
fi

FRONTEND_HOST=$1
EXTENSION_PUBLISH_PORT=${2:-5000}
if [[ -z $FRONTEND_HOST ]]; then
    echo "Usage: $0 {frontend_host} {extension_publish_port:5000}"
    exit 1
fi

export FRONTEND_HOST
export EXTENSION_PUBLISH_PORT
echo "Frontend Host: $FRONTEND_HOST"
echo "Extension publish port: $EXTENSION_PUBLISH_PORT"

TRAEFIK_LOCAL_HTTPS_PORT=8080
STACK_NAME=nexus
COMPOSE_YML=11-nexus-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Web url: https://${FRONTEND_HOST}:${TRAEFIK_LOCAL_HTTPS_PORT}"
echo "  Default username: admin"
echo "  Default password: admin123"
echo "  Docker extension port: 8082"
echo "Done ($CODE)."

