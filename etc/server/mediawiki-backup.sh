#!/usr/bin/env bash

MEDIAWIKI_ROOT=/var/www/html
MAINTENANCE_DIR=$MEDIAWIKI_ROOT/maintenance

DATE_FORMAT=`date +%Y%m%d_%H-%M-%S`
DB_XML_NAME=wiki-db-$DATE_FORMAT.xml
FILE_TAR_NAME=wiki-file-$DATE_FORMAT.tar.gz

CLEANUP=true

php $MAINTENANCE_DIR/dumpBackup.php --full --uploads > $DB_XML_NAME
tar czf $DB_XML_NAME.tar.gz $DB_XML_NAME
tar czf $FILE_TAR_NAME $MEDIAWIKI_ROOT

if [[ "$CLEANUP" == true ]]; then
    rm $DB_XML_NAME
fi

echo "Done ($?)."


