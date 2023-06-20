#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

if ! command -v shellcheck &> /dev/null; then
    echo "Not found shellcheck command" 1>&2
    exit 1
fi

shellcheck --source-path="$ROOT_DIR/bin" "$@" "$ROOT_DIR"/bin/*
