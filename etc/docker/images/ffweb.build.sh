#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

FILE="$ROOT_DIR/ffweb.dockerfile"
TAG="osom8979/ffweb:latest"

docker build -f "$FILE" -t "$TAG" "$ROOT_DIR"
