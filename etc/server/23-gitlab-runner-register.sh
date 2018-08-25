#!/usr/bin/env bash

CONTAINER_ID=$1
URL=$2
REGISTRATION_TOKEN=$3
TAG_LIST=$4
DOCKER_IMAGE=${5:-alpine}

if [[ -z $CONTAINER_ID || -z $URL || -z $REGISTRATION_TOKEN || -z $TAG_LIST || -z $DOCKER_IMAGE ]]; then
    echo "Usage: $0 {container} {url} {token} {tags} {docker_image:alpine}"
    exit 1
fi

echo "Container ID: $CONTAINER_ID"
echo "URL: $URL"
echo "Token: $REGISTRATION_TOKEN"
echo "Tag-list: $TAG_LIST"
echo "Docker image: $DOCKER_IMAGE"

docker exec $CONTAINER_ID gitlab-runner register \
    --non-interactive \
    --executor "docker" \
    --docker-image $DOCKER_IMAGE \
    --url "$URL" \
    --registration-token "$REGISTRATION_TOKEN" \
    --description "docker-runner" \
    --tag-list "$TAG_LIST" \
    --run-untagged \
    --locked="false"
CODE=$?

echo "Done ($CODE)."

