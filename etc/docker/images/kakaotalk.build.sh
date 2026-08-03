#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

FILE="$ROOT_DIR/kakaotalk.dockerfile"
TAG="${KAKAO_IMAGE:-osom8979/kakaotalk:latest}"

docker build -f "$FILE" -t "$TAG" "$ROOT_DIR"
