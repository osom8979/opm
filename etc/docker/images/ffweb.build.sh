#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

FILE="$ROOT_DIR/ffweb.dockerfile"
TAG="ffweb:latest"

docker build -f "$FILE" -t "$TAG" "$ROOT_DIR"
