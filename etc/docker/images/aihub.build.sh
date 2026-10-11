#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

FILE="$ROOT_DIR/aihub.dockerfile"
TAG="${AIHUB_IMAGE:-osom8979/aihub:latest}"

docker build -f "$FILE" -t "$TAG" "$ROOT_DIR"
