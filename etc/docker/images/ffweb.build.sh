#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

docker build -t osom8979/ffweb:latest -f "$ROOT_DIR/ffweb.dockerfile" "$ROOT_DIR"

