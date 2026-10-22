#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
# shellcheck source=common.sh
source "$ROOT_DIR/common.sh"

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

# Extract before stopping the services to keep the downtime short
mkdir -p "$BACKUP_DIR"
STAGE=$(mktemp -d "$BACKUP_DIR/.restore.XXXXXX")
trap 'rm -rf "$STAGE"' EXIT

for ARCHIVE in "$@"; do
    print_message "Extract the archive: '$ARCHIVE'"
    if ! extract_archive "$ARCHIVE" "$STAGE"; then
        print_error "Archive extraction failed: '$ARCHIVE'"
        exit 1
    fi
done

mapfile -t ITEMS < <(existing_items "$STAGE" "${STATE_ITEMS[@]}")
if [[ ${#ITEMS[@]} -eq 0 ]]; then
    print_error "Nothing to restore in the archives"
    exit 1
fi

# A new server has no .env yet, and compose cannot read its file without it
if [[ ! -e $ROOT_DIR/.env && -f $STAGE/.env ]]; then
    cp -p "$STAGE/.env" "$ROOT_DIR/.env"
fi

if [[ -f $STAGE/backup.info ]]; then
    print_message "Backup info:"
    sed 's/^/ /' "$STAGE/backup.info"

    for SERVICE in mediawiki mariadb; do
        KEY=$(echo "$SERVICE" | tr '[:lower:]' '[:upper:]')_IMAGE
        BACKUP_IMAGE=$(sed -n "s/^$KEY=//p" "$STAGE/backup.info")
        CURRENT_IMAGE=$(service_image "$SERVICE")
        if [[ "$BACKUP_IMAGE" != "$CURRENT_IMAGE" ]]; then
            print_error "The '$SERVICE' image differs: $BACKUP_IMAGE (backup) != $CURRENT_IMAGE (current)"
        fi
    done
fi

print_message "The following items will be replaced: ${ITEMS[*]}"
read -r -p "Type 'yes' to continue: " ANSWER
if [[ $ANSWER != yes ]]; then
    print_error "Canceled"
    exit 1
fi

print_message "Stop services ..."
compose stop mediawiki mariadb || exit 1

# Keep the current items until the restored wiki is confirmed
KEEP_DIR=$BACKUP_DIR/before-restore-$(date +%Y%m%d-%H%M%S)
mkdir -p "$KEEP_DIR"

for ITEM in "${ITEMS[@]}"; do
    TARGET=$ROOT_DIR/$ITEM
    if [[ -e $TARGET ]]; then
        mv "$TARGET" "$KEEP_DIR/"
    fi
    mv "$STAGE/$ITEM" "$TARGET"
done
rmdir "$KEEP_DIR" 2> /dev/null

# The older plain 7z archives do not keep file owners.
# MariaDB fixes its data directory by itself, but uploads need www-data (33).
if [[ -d $ROOT_DIR/images ]]; then
    chown -R 33:33 "$ROOT_DIR/images"
fi

print_message "Restore complete: ${ITEMS[*]}"
if [[ -d $KEEP_DIR ]]; then
    print_message " Previous items: '$KEEP_DIR'"
fi
echo "Check the image tags in docker-compose.yml, then start the services:"
echo "  docker compose up -d"
