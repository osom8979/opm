#!/usr/bin/env bash

LOCALSETTINGS_PATH=$1
if [[ -z $LOCALSETTINGS_PATH ]]; then
    echo "Usage: $0 {localsettings_path}"
    exit 1
fi

if [[ ! -f "$LOCALSETTINGS_PATH" ]]; then
    echo "Not found $LOCALSETTINGS_PATH file"
    exit 1
fi

CONTAINER_ID=`docker ps | grep mediawiki_web | awk '{printf("%s\n", $1);}' | head -1`
if [[ -z $CONTAINER_ID ]]; then
    echo "Not found $CONTAINER_ID container"
    exit 1
fi

echo "Container ID: $CONTAINER_ID"
echo "LocalSettings.php path: $LOCALSETTINGS_PATH"

docker cp "$LOCALSETTINGS_PATH" "$CONTAINER_ID:/var/www/html/LocalSettings.php"
echo 'Done.'

