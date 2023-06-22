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

BACKUP_DATE=$1

MEDIAWIKI_ROOT=/var/www/html
MAINTENANCE_DIR=$MEDIAWIKI_ROOT/maintenance
IMAGES_DIR=$MEDIAWIKI_ROOT/images
BACKUP_ROOT=/backup
BACKUP_DIR=$BACKUP_ROOT/$BACKUP_DATE
CLEANUP=1

if [[ -z $BACKUP_DATE ]]; then
    print_error "Usage: ${BASH_SOURCE[0]} {key}"
    echo 'List of kyes:'
    find /backup -maxdepth 1 -mindepth 1 -type d -printf ' - %f\n'
    exit 1
fi

if [[ ! -d $BACKUP_DIR ]]; then
    print_error "Not found '$BACKUP_DIR' directory"
    exit 1
fi

DB_TAR_NAME=$BACKUP_DIR/db.tar.gz
IMAGES_TAR_NAME=$BACKUP_DIR/images.tar.gz

if [[ ! -f $DB_TAR_NAME ]]; then
    print_error "Not found '$DB_TAR_NAME' file"
    exit 1
fi

if [[ ! -f $IMAGES_TAR_NAME ]]; then
    print_error "Not found '$IMAGES_TAR_NAME' file"
    exit 1
fi

TEMP_DIR=$BACKUP_DIR/temp
if [[ -d "$TEMP_DIR" ]]; then
    print_message "Remove the existing temp directory: '$TEMP_DIR'"
    rm -rf "$TEMP_DIR"
fi

print_message "Create temp directory: '$TEMP_DIR'"
mkdir -pv "$TEMP_DIR"

print_message "Extract the backup file: '$DB_TAR_NAME'"
tar xzf "$DB_TAR_NAME" --strip-components=2 -C "$TEMP_DIR"
CODE=$?

if [[ $CODE -ne 0 ]]; then
    print_error "Backup file extraction failed: $CODE"
    exit $CODE
fi

DB_XML=$TEMP_DIR/db.xml
if [[ ! -f "$DB_XML" ]]; then
    print_error "Not found '$DB_XML' file"
    exit 1
fi

print_message "Database importing ..."
php "$MAINTENANCE_DIR/importDump.php" "$DB_XML"
CODE=$?

if [[ $CODE -ne 0 ]]; then
    print_error "Import database failed: $CODE"
    exit $CODE
fi

print_message "Remove unnecessary file: '$DB_XML'"
rm "$DB_XML"

print_message "Extract the images: '$IMAGES_TAR_NAME'"
tar xzf "$IMAGES_TAR_NAME" --strip-components=4 -C "$TEMP_DIR"
CODE=$?

if [[ $CODE -ne 0 ]]; then
    print_error "Images extraction failed: $CODE"
    exit $CODE
fi

EXTS=(
    7Z BZ2 C CPP GIF GZ JAVA JPEG JPG MP4 PDF PNG SVG TXT XZ ZIP
    7z bz2 c cpp gif gz java jpeg jpg mp4 pdf png svg txt xz zip
       Bz2 C Cpp Gif Gz Java Jpeg Jpg Mp4 Pdf Png Svg Txt Xz Zip
)

print_message "Images importing ..."
php "$MAINTENANCE_DIR/importImages.php" --search-recursively "$BACKUP_IMAGES_DIR" "${EXTS[@]}"
CODE=$?

if [[ $CODE -ne 0 ]]; then
    print_error "Import images failed: $CODE"
    exit $CODE
fi

print_message "Rebuild recent changes ..."
php "$MAINTENANCE_DIR/rebuildrecentchanges.php"
CODE=$?

if [[ $CODE -ne 0 ]]; then
    print_error "Rebuild recent changes failed: $CODE"
    exit $CODE
fi

print_message "Run jobs ..."
php "$MAINTENANCE_DIR/runJobs.php"
CODE=$?

if [[ $CODE -ne 0 ]]; then
    print_error "Run jobs failed: $CODE"
    exit $CODE
fi

print_message "Update 'www-data' owner and group ..."
chown -R www-data:www-data "$IMAGES_DIR"

if [[ $CLEANUP -ne 0 ]]; then
    print_message "Remove unnecessary directory: '$TEMP_DIR'"
    rm -rf "$TEMP_DIR"
fi

echo "List of manually settings:"
echo " - UPDATE [[MediaWiki:Sidebar]]"
echo " - REDIRECT [[mainpage]] to [[Osom:MainPage]]"
