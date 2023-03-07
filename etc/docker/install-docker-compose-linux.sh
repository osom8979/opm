#!/usr/bin/env bash

DOCKER_COMPOSE_VERSION=1.29.2
FILENAME="docker-compose-$(uname -s)-$(uname -m)"
URL_PREFIX="https://github.com/docker/compose/releases/download"
URL="$URL_PREFIX/$DOCKER_COMPOSE_VERSION/$FILENAME"
DEST=/usr/local/bin/docker-compose

sudo curl -L "$URL" -o "$DEST"
sudo chmod +x "$DEST"
