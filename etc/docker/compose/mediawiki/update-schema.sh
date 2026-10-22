#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

docker compose -f "$ROOT_DIR/docker-compose.yml" run --rm --no-deps --user www-data \
    mediawiki php maintenance/run.php update --quick "$@"
