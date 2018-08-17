#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

LOCALSETTINGS=$1
if [[ -z $LOCALSETTINGS ]]; then
    echo "Usage: $0 {localsettings_path}"
    exit 1
fi
if [[ ! -f "$LOCALSETTINGS" ]]; then
    echo "Not found $LOCALSETTINGS file"
    exit 1
fi

OPT_DIR=/opt/mediawiki
LOCALSETTINGS_PATH=$OPT_DIR/LocalSettings.php
if [[ -f "$LOCALSETTINGS_PATH" ]]; then
    echo "Exists $LOCALSETTINGS_PATH file"
    exit 1
fi

CONTAINER_ID=`docker service ls | grep mediawiki_web | awk '{printf("%s\n", $1);}' | head -1`
if [[ -z $CONTAINER_ID ]]; then
    echo "Not found $CONTAINER_ID container"
    exit 1
fi

echo "Container ID: $CONTAINER_ID"
echo "LocalSettings.php path: $LOCALSETTINGS"

if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

echo "Create $LOCALSETTINGS_PATH file"
cp "$LOCALSETTINGS" "$LOCALSETTINGS_PATH"

echo 'Update file extensions ...'
echo '## FileExtensions:'            >> "$LOCALSETTINGS_PATH"
echo '$wgFileExtensions[] =  "png";' >> "$LOCALSETTINGS_PATH"
echo '$wgFileExtensions[] =  "gif";' >> "$LOCALSETTINGS_PATH"
echo '$wgFileExtensions[] =  "jpg";' >> "$LOCALSETTINGS_PATH"
echo '$wgFileExtensions[] = "jpeg";' >> "$LOCALSETTINGS_PATH"
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

echo "Update service ..."
docker service update \
    --mount-add \
    type=bind,source=/opt/mediawiki/LocalSettings.php,target=/var/www/html/LocalSettings.php \
    "$CONTAINER_ID"

echo "Done ($?)."

