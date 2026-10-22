#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
# shellcheck source=common.sh
source "$ROOT_DIR/common.sh"

DB_NAME=my_wiki
DB_PREFIX=wiki
TIMEOUT=600

if [[ $# -eq 0 ]]; then
    print_error "Usage: ${BASH_SOURCE[0]} {archive} [archive ...]"
    list_backups
    exit 1
fi

require_root
require_7za

for ARCHIVE in "$@"; do
    if [[ ! -f $ARCHIVE ]]; then
        print_error "Not found '$ARCHIVE' file"
        exit 1
    fi
done

read_password

mkdir -p "$BACKUP_DIR"
STAGE=$(mktemp -d "$BACKUP_DIR/.verify.XXXXXX")
CONTAINER=mediawiki-verify-$$

function cleanup
{
    docker rm -f "$CONTAINER" &> /dev/null
    rm -rf "$STAGE"
}
trap cleanup EXIT

function wait_for_mariadb
{
    local i
    for (( i = 0; i < TIMEOUT; i++ )); do
        if [[ $(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2> /dev/null) != true ]]; then
            return 1
        fi
        # The temporary server of the first initialization listens on port 0
        if docker logs "$CONTAINER" 2>&1 | grep -q 'port: 3306'; then
            return 0
        fi
        sleep 1
    done
    return 1
}

for ARCHIVE in "$@"; do
    print_message "Verify the checksum: '$ARCHIVE'"
    if ! verify_checksum "$ARCHIVE"; then
        print_error "Checksum mismatch: '$ARCHIVE'"
        exit 1
    fi

    print_message "Extract the archive: '$ARCHIVE'"
    if ! extract_archive "$ARCHIVE" "$STAGE"; then
        print_error "Archive extraction failed: '$ARCHIVE'"
        exit 1
    fi
done

# Raw data files only open with the MariaDB version that wrote them
if [[ -z $MARIADB_IMAGE && -f $STAGE/backup.info ]]; then
    MARIADB_IMAGE=$(sed -n 's/^MARIADB_IMAGE=//p' "$STAGE/backup.info")
fi
if [[ -z $MARIADB_IMAGE ]]; then
    MARIADB_IMAGE=$(service_image mariadb)
    print_error "Unknown MariaDB version of the backup, using '$MARIADB_IMAGE' (set MARIADB_IMAGE to override)"
fi
if [[ -z $MARIADB_IMAGE ]]; then
    print_error "Unknown MariaDB image, please set MARIADB_IMAGE"
    exit 1
fi

if [[ -d $STAGE/mysql ]]; then
    print_message "Start MariaDB on the raw data: $MARIADB_IMAGE"
    docker run -d --name "$CONTAINER" --network none \
        -v "$STAGE/mysql:/var/lib/mysql" \
        "$MARIADB_IMAGE" --skip-grant-tables > /dev/null
elif [[ -f $STAGE/database.sql ]]; then
    print_message "Start an empty MariaDB: $MARIADB_IMAGE"
    docker run -d --name "$CONTAINER" --network none \
        -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1 -e MARIADB_DATABASE="$DB_NAME" \
        "$MARIADB_IMAGE" > /dev/null
else
    print_error "Not found a database in the archives"
    exit 1
fi

if ! wait_for_mariadb; then
    print_error "MariaDB failed to start"
    docker logs --tail 30 "$CONTAINER"
    exit 1
fi

if [[ ! -d $STAGE/mysql ]]; then
    print_message "Import the database dump ..."
    if ! docker exec -i "$CONTAINER" mariadb "$DB_NAME" < "$STAGE/database.sql"; then
        print_error "Database import failed"
        exit 1
    fi
fi

print_message "Check all tables ..."
docker exec "$CONTAINER" mariadb-check --all-databases > "$STAGE/check.log" 2>&1
CODE=$?
PROBLEMS=$(grep -i -E '^(error|warning)[[:space:]]*:' "$STAGE/check.log")
if [[ $CODE -ne 0 || -n $PROBLEMS ]]; then
    print_error "Table check failed: $CODE"
    echo "${PROBLEMS:-$(tail -n 30 "$STAGE/check.log")}"
    exit 1
fi

read -r PAGES LAST_EDIT < <(docker exec "$CONTAINER" mariadb -N -B -e "
    SELECT
        (SELECT COUNT(*) FROM \`$DB_NAME\`.\`${DB_PREFIX}page\`),
        (SELECT MAX(rev_timestamp) FROM \`$DB_NAME\`.\`${DB_PREFIX}revision\`)
")
if [[ -z $PAGES ]]; then
    print_error "Not found the wiki tables: $DB_NAME.${DB_PREFIX}page"
    exit 1
fi

print_message "Verification passed"
echo " Tables    : $(grep -c -E '[[:space:]]OK$' "$STAGE/check.log") OK"
echo " Pages     : $PAGES"
echo " Last edit : ${LAST_EDIT:0:4}-${LAST_EDIT:4:2}-${LAST_EDIT:6:2} ${LAST_EDIT:8:2}:${LAST_EDIT:10:2}:${LAST_EDIT:12:2} UTC"
if [[ -d $STAGE/images ]]; then
    echo " Images    : $(find "$STAGE/images" -type f | wc -l) files, $(du -sh "$STAGE/images" | cut -f1)"
fi
for FILE in LocalSettings.php .env; do
    if [[ -f $STAGE/$FILE ]]; then
        echo " $FILE : included"
    fi
done
