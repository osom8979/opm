#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

cd "$ROOT_DIR" && "$ROOT_DIR/python" setup.py bdist_wheel
