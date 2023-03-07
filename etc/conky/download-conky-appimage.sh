#!/usr/bin/env bash

if ! command -v curl &> /dev/null; then
    echo "Not found curl command" 1>&2
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Not found jq command" 1>&2
    exit 1
fi

JSON_URL="https://api.github.com/repos/brndnmtthws/conky/releases/latest"
DEST=$(opm-home)/var/bin/conky-x86_64.AppImage
JSON_PATH=".assets[0] | .browser_download_url"
URL=$(curl -sL "$JSON_URL" | jq --raw-output "$JSON_PATH")

curl -sL -o "$DEST" "$URL"
chmod +x "$DEST"
