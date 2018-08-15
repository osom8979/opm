#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

STACK_NAME=mediawiki-stack
SECRET_NAME=wikiuser-pw
SECRET_EXISTS=`docker secret ls | grep $SECRET_NAME`

if [[ -z $SECRET_EXISTS ]]; then
    read -sp 'Enter the password: ' WIKIUSER_PW
    echo -e "\nCreate $SECRET_NAME secret"
    echo "$WIKIUSER_PW" | docker secret create "$SECRET_NAME" -
else
    echo "Exists $SECRET_NAME"
fi

OPT_DIR=/opt/mediawiki
SETTING_DEST="$OPT_DIR/LocalSettings.php"

if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

COMPOSE_NAME=mediawiki-compose.yml

if [[ ! -f "$COMPOSE_NAME" ]]; then
    echo "Not found $COMPOSE_NAME file"
    exit 1
fi

if [[ -f "$SETTING_DEST" ]]; then
    echo "Exists $SETTING_DEST file"
else
    echo "Create $SETTING_DEST file"
    touch "$SETTING_DEST" # && chmod 600 "$SETTING_DEST"
fi

echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_NAME" "$STACK_NAME"

echo 'Done.'

