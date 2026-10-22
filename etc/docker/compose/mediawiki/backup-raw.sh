#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
# shellcheck source=common.sh
source "$ROOT_DIR/common.sh"

require_root
require_7za
read_password confirm

ARCHIVE=$BACKUP_DIR/raw-$(date +%Y%m%d-%H%M%S).tar.7z
mkdir -p "$BACKUP_DIR"
STAGE=$(mktemp -d "$BACKUP_DIR/.raw.XXXXXX")
write_backup_info "$STAGE/backup.info"

# Start again only the services stopped by this script
STOPPED=()
for SERVICE in mariadb mediawiki; do
    if is_running "$SERVICE"; then
        STOPPED+=("$SERVICE")
    fi
done

function cleanup
{
    rm -rf "$STAGE"
    if [[ ${#STOPPED[@]} -gt 0 ]]; then
        print_message "Start services: ${STOPPED[*]}"
        compose start "${STOPPED[@]}"
    fi
}
trap cleanup EXIT

# Copying the files of a running database gives an inconsistent snapshot
print_message "Stop services ..."
compose stop mediawiki mariadb || exit 1

mapfile -t ITEMS < <(existing_items "$ROOT_DIR" "${STATE_ITEMS[@]}")

print_message "Raw backup starts: ${ITEMS[*]}"
time create_archive "$ARCHIVE" -C "$STAGE" backup.info -C "$ROOT_DIR" "${ITEMS[@]}"
CODE=$?
if [[ $CODE -ne 0 ]]; then
    print_error "Raw backup failed: $CODE"
    exit $CODE
fi

print_message "Backup complete: '$ARCHIVE' ($(du -h "$ARCHIVE" | cut -f1))"
print_message " Checksum: '$ARCHIVE.sha256'"
