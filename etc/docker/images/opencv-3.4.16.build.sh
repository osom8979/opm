#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

FILE="$ROOT_DIR/opencv-3.4.16.dockerfile"
TAG="openv:3.4.16"

docker build -f "$FILE" -t "$TAG" "$ROOT_DIR"
