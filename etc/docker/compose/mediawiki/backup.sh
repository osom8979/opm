#!/usr/bin/env bash

function print_error
{
    # shellcheck disable=SC2145
    echo -e "\033[31m$@\033[0m" 1>&2
}

function print_message
{
    # shellcheck disable=SC2145
    echo -e "\033[32m$@\033[0m"
}

CLEANUP=1

MEDIAWIKI_ROOT=/var/www/html
BACKUP_SCRIPT=$MEDIAWIKI_ROOT/maintenance/dumpBackup.php
IMAGES_DIR=$MEDIAWIKI_ROOT/images

BACKUP_ROOT=/backup
DATE_FORMAT=$(date +%Y%m%d)
BACKUP_DIR=$BACKUP_ROOT/$DATE_FORMAT

if [[ -d "$BACKUP_DIR" ]]; then
    print_error "Exists backup directory: '$BACKUP_DIR'"
    exit 1
fi

print_message "Create backup directory: "
mkdir -p "$BACKUP_DIR"

DB_XML_NAME=$BACKUP_DIR/db.xml
DB_TAR_NAME=$BACKUP_DIR/db.tar.gz
IMAGES_TAR_NAME=$BACKUP_DIR/images.tar.gz

print_message "MediaWiki backup starts ..."
php "$BACKUP_SCRIPT" --full --uploads > "$DB_XML_NAME"
CODE=$?

if [[ $CODE -ne 0 ]]; then
    print_error "MediaWiki backup failed $CODE"
    rm -fv "$DB_XML_NAME"
    exit $CODE
fi

print_message "Compress the backup file ..."
tar czf "$DB_TAR_NAME" "$DB_XML_NAME"
CODE=$?

if [[ $CODE -ne 0 ]]; then
    print_error "Backup file compression failed: $CODE"
    rm -fv "$DB_TAR_NAME"
    exit $CODE
fi

print_message "Compress the images dir ..."
tar czf "$IMAGES_TAR_NAME" -C "$IMAGES_DIR" "$IMAGES_DIR"
CODE=$?

if [[ $CODE -ne 0 ]]; then
    print_error "Images dir compression failed: $CODE"
    rm -fv "$IMAGES_TAR_NAME"
    exit $CODE
fi

if [[ $CLEANUP -ne 0 ]]; then
    print_message "Remove unnecessary file: '$DB_XML_NAME'"
    rm -f "$DB_XML_NAME"
fi

print_message "Backup complete!"
print_message " Database: '$DB_TAR_NAME'"
print_message " Images: '$IMAGES_TAR_NAME'"
