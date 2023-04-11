#!/usr/bin/env bash

DOCKER_COMPOSE_VERSION=v2.17.2
PLATFORM=$(uname -s)
ARCHITECTURE=$(uname -m)
FILENAME="docker-compose-${PLATFORM,,}-${ARCHITECTURE}"
URL_PREFIX="https://github.com/docker/compose/releases/download"
URL="$URL_PREFIX/$DOCKER_COMPOSE_VERSION/$FILENAME"
DEST=/usr/local/bin/docker-compose

sudo curl -L "$URL" -o "$DEST"
sudo chmod +x "$DEST"
