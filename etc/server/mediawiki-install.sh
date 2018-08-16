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

OPT_DIR=/opt/mediawiki
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

BACKUP_TEMPLATE=mediawiki-backup.sh
if [[ ! -f "$BACKUP_TEMPLATE" ]]; then
    echo "Not found $BACKUP_TEMPLATE file"
    exit 1
fi

BACKUP_SCRIPT_PATH=$BACKUP_DIR/mediawiki-backup.sh
if [[ -f "$BACKUP_SCRIPT_PATH" ]]; then
    echo "Exists $BACKUP_SCRIPT_PATH file"
else
    echo "Create $BACKUP_SCRIPT_PATH file"
    cp "$BACKUP_TEMPLATE" "$BACKUP_SCRIPT_PATH" && chmod +x "$BACKUP_SCRIPT_PATH"
fi

COMPOSE_YML=mediawiki-compose.yml
if [[ ! -f "$COMPOSE_YML" ]]; then
    echo "Not found $COMPOSE_YML file"
    exit 1
fi

STACK_NAME=mediawiki
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Go to page $FRONTEND_HOST and continue setting."
echo "  Database type: MySQL"
echo "  Database host: mediawiki_db"
echo "  Database name: my_wiki"
echo "  Database table prefix: wiki"
echo "  Database username: wikiuser"
echo "  Extensions:"
echo "   - Cite"
echo "   - ConfirmEdit"
echo "   - Renameuser"
echo "   - SyntaxHighlight_GeSHi"
echo "   - WikiEditor"
echo "   - SimpleMathJax (https://github.com/jmnote/SimpleMathJax.git)"
echo "  FileExtensions:"
echo "   $wgFileExtensions[] = 'png';"
echo "   $wgFileExtensions[] = 'gif';"
echo "   $wgFileExtensions[] = 'jpg';"
echo "   $wgFileExtensions[] = 'jpeg';"
echo "   $wgFileExtensions[] = 'pdf';"
echo "   $wgFileExtensions[] = 'zip';"
echo "   $wgFileExtensions[] = 'gz';"
echo "   $wgFileExtensions[] = 'bz2';"
echo "   $wgFileExtensions[] = '7z';"
echo "   $wgFileExtensions[] = 'xz';"
echo "   $wgFileExtensions[] = 'java';"
echo "   $wgFileExtensions[] = 'c';"
echo "   $wgFileExtensions[] = 'cpp';"
echo "   $wgFileExtensions[] = 'txt';"
echo "Done ($?)."

