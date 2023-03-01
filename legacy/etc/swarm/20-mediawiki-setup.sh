#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

OPT_DIR=/opt/opm/mediawiki
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

LOCALSETTINGS_PATH=$OPT_DIR/LocalSettings.php
if [[ -f "$LOCALSETTINGS_PATH" ]]; then
    echo "Exists $LOCALSETTINGS_PATH file"
else
    LOCALSETTINGS=$1
    if [[ -z $LOCALSETTINGS ]]; then
        echo "Usage: $0 {localsettings_path}"
        exit 1
    fi
    if [[ ! -f "$LOCALSETTINGS" ]]; then
        echo "Not found $LOCALSETTINGS file"
        exit 1
    fi

    echo "Create $LOCALSETTINGS_PATH file"
    cp "$LOCALSETTINGS" "$LOCALSETTINGS_PATH"

    echo 'Update file extensions ...'
    echo '## Maximum size of uploaded files (in bytes)' >> "$LOCALSETTINGS_PATH"
    echo '$wgMaxUploadSize = 256 * 1024 * 1024;'        >> "$LOCALSETTINGS_PATH"
    echo '## FileExtensions:'            >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =  "png";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =  "gif";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =  "jpg";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] = "jpeg";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =  "svg";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =  "pdf";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =  "zip";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =   "gz";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =  "bz2";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =   "7z";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =   "xz";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] = "java";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =    "c";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =  "cpp";' >> "$LOCALSETTINGS_PATH"
    echo '$wgFileExtensions[] =  "txt";' >> "$LOCALSETTINGS_PATH"
fi

CONTAINER_NAME=mediawiki_web
CONTAINER_ID=`docker service ls | grep $CONTAINER_NAME | awk '{printf("%s\n", $1);}' | head -1`
if [[ -z $CONTAINER_ID ]]; then
    echo "Not found container"
    exit 1
else
    echo "Found $CONTAINER_NAME container: $CONTAINER_ID"
fi

echo "Update service ..."
docker service update \
    --mount-add \
    "type=bind,source=$LOCALSETTINGS_PATH,target=/var/www/html/LocalSettings.php" \
    "$CONTAINER_ID"
CODE=$?

echo "Done ($CODE)."

