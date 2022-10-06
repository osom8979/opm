#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

"$ROOT_DIR/python" -m pip uninstall %PROJECT_NAME%
