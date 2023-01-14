#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

if ! "$ROOT_DIR/python" --version > /dev/null; then
    echo "An error occurred in the Python script $?" 1>&2
    exit 1
fi

ACTIVATE_PATH="$ROOT_DIR/.venv/bin/activate"
if [[ ! -f "$ACTIVATE_PATH" ]]; then
    echo "Not found activate script: $ACTIVATE_PATH" >&2
    exit 1
fi

source "$ACTIVATE_PATH"

cd "$ROOT_DIR" && pyinstaller \
    --onefile \
    --clean \
    --noconsole \
    --add-data "%PROJECT_LOWER%/www:www" \
    "$ROOT_DIR/main.py"
