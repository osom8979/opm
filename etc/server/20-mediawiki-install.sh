#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

FRONTEND_HOST=$1
if [[ -z $FRONTEND_HOST ]]; then
    echo "Usage: $0 {frontend_host}"
    exit 1
fi

export FRONTEND_HOST
echo "Frontend Host: $FRONTEND_HOST"

SECRET_NAME=mediawiki-wikiuser-pw
SECRET_EXISTS=`docker secret ls | grep $SECRET_NAME`
if [[ -z $SECRET_EXISTS ]]; then
    read -sp "Enter the docker-secret ($SECRET_NAME) password: " SECRET_VALUE
    echo -e "\nCreate $SECRET_NAME secret"
    echo "$SECRET_VALUE" | docker secret create "$SECRET_NAME" -
else
    echo "Exists $SECRET_NAME"
fi

OPT_DIR=/opt/opm/mediawiki
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

BACKUP_DIR=$OPT_DIR/backup
if [[ -d "$BACKUP_DIR" ]]; then
    echo "Exists $BACKUP_DIR directory"
else
    echo "Create $BACKUP_DIR directory"
    mkdir -p "$BACKUP_DIR"
fi

BACKUP_TEMPLATE=20-mediawiki-backup.sh
BACKUP_SCRIPT_PATH=$BACKUP_DIR/mediawiki-backup.sh
if [[ -f "$BACKUP_SCRIPT_PATH" ]]; then
    echo "Exists $BACKUP_SCRIPT_PATH file"
else
    echo "Create $BACKUP_SCRIPT_PATH file"
    cp "$BACKUP_TEMPLATE" "$BACKUP_SCRIPT_PATH" && chmod +x "$BACKUP_SCRIPT_PATH"
fi

IMPORT_TEMPLATE=20-mediawiki-import.sh
IMPORT_SCRIPT_PATH=$BACKUP_DIR/mediawiki-import.sh
if [[ -f "$IMPORT_SCRIPT_PATH" ]]; then
    echo "Exists $IMPORT_SCRIPT_PATH file"
else
    echo "Create $IMPORT_SCRIPT_PATH file"
    cp "$IMPORT_TEMPLATE" "$IMPORT_SCRIPT_PATH" && chmod +x "$IMPORT_SCRIPT_PATH"
fi

PHPCONFIG_TEMPLATE=20-mediawiki-phpconfig.ini
PHPCONFIG_INI_PATH=$OPT_DIR/mediawiki-phpconfig.ini
if [[ -f "$PHPCONFIG_INI_PATH" ]]; then
    echo "Exists $PHPCONFIG_INI_PATH file"
else
    echo "Create $PHPCONFIG_INI_PATH file"
    cp "$PHPCONFIG_TEMPLATE" "$PHPCONFIG_INI_PATH"
fi


LOGO_NAME=20-mediawiki-logo.png
LOGO_PATH=$OPT_DIR/osom-logo.png
if [[ -f "$LOGO_PATH" ]]; then
    echo "Exists $LOGO_PATH file"
else
    echo "Create $LOGO_PATH file"
    cp "$LOGO_NAME" "$LOGO_PATH"
fi

SIMPLEMATHJAX_DIR="$OPT_DIR/SimpleMathJax"
if [[ ! -d $SIMPLEMATHJAX_DIR ]]; then
    git clone --depth 1 https://github.com/jmnote/SimpleMathJax.git "$SIMPLEMATHJAX_DIR"
fi

STACK_NAME=mediawiki
COMPOSE_YML=20-mediawiki-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Go to page $FRONTEND_HOST and continue setting."
echo '  Database type: MySQL'
echo '  Database host: mediawiki_db'
echo '  Database name: my_wiki'
echo '  Database table prefix: wiki'
echo '  Database username: wikiuser'
echo '  Extensions:'
echo '   - Cite'
echo '   - ConfirmEdit'
echo '   - Renameuser'
echo '   - SyntaxHighlight_GeSHi'
echo '   - WikiEditor'
echo '   - SimpleMathJax (https://github.com/jmnote/SimpleMathJax.git)'
echo "Done ($CODE)."

