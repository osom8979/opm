#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

FILE="$ROOT_DIR/turnserver.dockerfile"
TAG="turnserver:latest"

docker build -f "$FILE" -t "$TAG" "$ROOT_DIR"
