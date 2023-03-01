#!/usr/bin/env bash

URL=$1                      # https://git.test.site/
REGISTRATION_TOKEN=$2       # aKw3RAukuZgPqwRzgnCz
TAG_LIST=$3                 # common
DOCKER_IMAGE=${4:-alpine}

if [[ -z $URL || -z $REGISTRATION_TOKEN || -z $TAG_LIST || -z $DOCKER_IMAGE ]]; then
    echo "Usage: $0 {url} {token} {tags} {docker_image:alpine}"
    exit 1
fi

echo "URL: $URL"
echo "Token: $REGISTRATION_TOKEN"
echo "Tag-list: $TAG_LIST"
echo "Docker image: $DOCKER_IMAGE"

CONTAINER_LIST=`docker ps --all | grep gitlab_runner | awk '{printf("%s\n", $1);}'`
REGISTER_SCRIPT=23-gitlab-runner-register.sh

for i in $CONTAINER_LIST; do
    "$SHELL" "$REGISTER_SCRIPT" "$i" "$URL" "$REGISTRATION_TOKEN" "$TAG_LIST" "$DOCKER_IMAGE"
done

echo "Loop done."

