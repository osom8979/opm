#!/usr/bin/env bash

if [[ $(which curl &> /dev/null) ]]; then
    echo "Not found curl" 1>&2
    exit 1
fi

if [[ $(which jq &> /dev/null) ]]; then
    echo "Not found jq" 1>&2
    exit 1
fi

CONKY_PATH=${OPM_HOME}/bin/conky-x86_64.AppImage

curl -sL -o "${CONKY_PATH}" \
    $(curl -sL https://api.github.com/repos/brndnmtthws/conky/releases/latest | \
    jq --raw-output '.assets[0] | .browser_download_url')
chmod +x ${CONKY_PATH}

