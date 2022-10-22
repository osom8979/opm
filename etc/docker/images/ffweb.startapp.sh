#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export HOME=/config
export PROFILE_DIR=$HOME/profile
export EXTENSIONS_DIR=$PROFILE_DIR/extensions

export VDH_EXT_OUT=/vdh.xpi

export OUTPUT_LOG=$HOME/log/firefox/output.log
export ERROR_LOG=$HOME/log/firefox/error.log

mkdir -p "$PROFILE_DIR"
mkdir -p "$EXTENSIONS_DIR"

unzip -p "$VDH_EXT_OUT" manifest.json \
    | jq .applications.gecko.id \
    | sed 's/"//g' \
    | xargs -I {} cp -v "$VDH_EXT_OUT" "$EXTENSIONS_DIR/{}.xpi"

firefox --version

exec /usr/bin/firefox_wrapper \
    --profile "$PROFILE_DIR" \
    --setDefaultBrowser \
    >> "$OUTPUT_LOG" \
    2>> "$ERROR_LOG"
