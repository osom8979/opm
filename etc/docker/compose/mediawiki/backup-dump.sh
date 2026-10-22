#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
# shellcheck source=common.sh
source "$ROOT_DIR/common.sh"

require_root
require_7za

if ! is_running mariadb; then
    print_error "The 'mariadb' service is not running"
    exit 1
fi

read_password confirm

ARCHIVE=$BACKUP_DIR/dump-$(date +%Y%m%d-%H%M%S).tar.7z
mkdir -p "$BACKUP_DIR"
STAGE=$(mktemp -d "$BACKUP_DIR/.dump.XXXXXX")
trap 'rm -rf "$STAGE"' EXIT
write_backup_info "$STAGE/backup.info"

# --single-transaction takes a consistent snapshot without stopping the wiki
print_message "Database dump starts ..."
# shellcheck disable=SC2016
time compose exec -T mariadb sh -c '
    export MYSQL_PWD="$MYSQL_PASSWORD"
    exec mariadb-dump -u"$MYSQL_USER" --single-transaction --quick \
        --default-character-set=binary "$MYSQL_DATABASE"
' > "$STAGE/database.sql"
CODE=$?
if [[ $CODE -ne 0 ]]; then
    print_error "Database dump failed: $CODE"
    exit $CODE
fi

mapfile -t ITEMS < <(existing_items "$ROOT_DIR" images LocalSettings.php .env)

print_message "Archive starts: database.sql ${ITEMS[*]}"
time create_archive "$ARCHIVE" -C "$STAGE" backup.info database.sql -C "$ROOT_DIR" "${ITEMS[@]}"
CODE=$?
if [[ $CODE -ne 0 ]]; then
    print_error "Archive failed: $CODE"
    exit $CODE
fi

print_message "Backup complete: '$ARCHIVE' ($(du -h "$ARCHIVE" | cut -f1))"
print_message " Checksum: '$ARCHIVE.sha256'"
