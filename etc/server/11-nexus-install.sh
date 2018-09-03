#!/usr/bin/env bash

#DOCKER_IMAGE_NAME=nexus-repository-apt
#EXISTS_DOCKER_IMAGE=`docker images --all | grep $DOCKER_IMAGE_NAME`
#if [[ -z $EXISTS_DOCKER_IMAGE ]]; then
#    SRC="https://github.com/sonatype-nexus-community/nexus-repository-apt"
#    DEST=nexus-repository-apt
#    pushd $PWD
#    if [[ -d "$DEST/.git" ]]; then
#        cd $DEST
#        git pull
#    else
#        git clone --depth 1 "$SRC" "$DEST"
#        cd $DEST
#    fi
#
#    docker build -t $DOCKER_IMAGE_NAME:3.11.0 .
#    DOCKER_BUILD_CODE=$?
#    if [[ ! $DOCKER_BUILD_CODE -eq 0 ]]; then
#        echo "Docker build error ($DOCKER_BUILD_CODE)."
#        exit $DOCKER_BUILD_CODE
#    fi
#    popd
#fi

FRONTEND_HOST=$1
DOCKER_FRONTEND_HOST=$2
if [[ -z $FRONTEND_HOST || -z $DOCKER_FRONTEND_HOST ]]; then
    echo "Usage: $0 {frontend_host} {docker_frontend_host}"
    exit 1
fi

export FRONTEND_HOST
export DOCKER_FRONTEND_HOST
echo "Frontend Host: $FRONTEND_HOST"
echo "Docker Frontend Host: $DOCKER_FRONTEND_HOST"

STACK_NAME=nexus
COMPOSE_YML=11-nexus-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Web url: https://${FRONTEND_HOST}:8080"
echo "Web url: https://${DOCKER_FRONTEND_HOST}:8080"
echo "  Default username: admin"
echo "  Default password: admin123"
echo "  Docker extension port: 8082"
echo "Done ($CODE)."

