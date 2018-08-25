#!/usr/bin/env bash

BACKUP_XML_PATH=$1
BACKUP_IMAGES_DIR=$2

if [[ -z $BACKUP_XML_PATH || -z $BACKUP_IMAGES_DIR ]]; then
    echo "Usage: $0 {backup_xml_path} {backup_images_dir}"
    exit 1
fi
if [[ ! -f $BACKUP_XML_PATH ]]; then
    echo "Not found $BACKUP_XML_PATH file"
    exit 1
fi
if [[ ! -d $BACKUP_IMAGES_DIR ]]; then
    echo "Not found $BACKUP_IMAGES_DIR directory"
    exit 1
fi

MEDIAWIKI_ROOT=/var/www/html
MAINTENANCE_DIR=$MEDIAWIKI_ROOT/maintenance
IMAGES_DIR=$MEDIAWIKI_ROOT/images

php $MAINTENANCE_DIR/importDump.php "$BACKUP_XML_PATH"
php $MAINTENANCE_DIR/importImages.php --search-recursively "$BACKUP_IMAGES_DIR" \
    png gif jpg jpeg pdf zip gz bz2 7z xz java c cpp txt \
    Png Gif Jpg Jpeg Pdf Zip Gz Bz2    Xz Java   Cpp Txt \
    PNG GIF JPG JPEG PDF ZIP GZ BZ2 7Z XZ JAVA C CPP TXT
php $MAINTENANCE_DIR/rebuildrecentchanges.php
php $MAINTENANCE_DIR/runJobs.php

chown -R www-data:www-data "$IMAGES_DIR"

echo "Setting:"
echo "UPDATE [[MediaWiki:Sidebar]]"
echo "REDIRECT [[Osom:MainPage]]"
echo "Done."

