#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

rm -vrf \
    "$ROOT_DIR/.mypy_cache/" \
    "$ROOT_DIR/.pytest_cache/" \
    "$ROOT_DIR/.sphinx_cache/" \
    "$ROOT_DIR/build/" \
    "$ROOT_DIR/dist/" \
    "$ROOT_DIR/%PROJECT_LOWER%.egg-info/"
