# shellcheck shell=bash
#
# Shared helpers for the maintenance scripts.
# Set ROOT_DIR before sourcing this file.

BACKUP_DIR=$ROOT_DIR/backup
COMPOSE_PATH=$ROOT_DIR/docker-compose.yml

# Files and directories that hold the state of the wiki
# shellcheck disable=SC2034
STATE_ITEMS=(mysql images LocalSettings.php .env)

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

function compose
{
    docker compose -f "$COMPOSE_PATH" "$@"
}

# 'config --images {service}' also prints the images of the dependencies,
# so read the image from the canonical YAML instead.
function service_image
{
    compose config 2> /dev/null | awk -v service="$1:" '
        /^[^ ]/ { section = $1 }
        section == "services:" && /^  [^ ]/ { current = $1 }
        section == "services:" && current == service && /^    image: / { print $2; exit }
    '
}

function is_running
{
    [[ -n $(compose ps -q --status running "$1") ]]
}

function require_root
{
    if [[ $(id -u) -ne 0 ]]; then
        print_error "Please run as root"
        exit 1
    fi
}

function require_7za
{
    if ! command -v 7za &> /dev/null; then
        print_error "Not found '7za' command"
        print_error "Please run the following command:"
        print_error "  sudo apt install p7zip-full"
        exit 1
    fi
}

# Set PASS from BACKUP_PASSWORD, BACKUP_PASSWORD_FILE or a prompt.
# Pass 'confirm' to ask twice when prompting.
# shellcheck disable=SC2120
function read_password
{
    if [[ -n $BACKUP_PASSWORD ]]; then
        PASS=$BACKUP_PASSWORD
    elif [[ -n $BACKUP_PASSWORD_FILE ]]; then
        PASS=$(head -n 1 "$BACKUP_PASSWORD_FILE")
    else
        read -s -r -p "Enter a archive password: " PASS
        echo -n -e "\n"
        if [[ $1 == confirm ]]; then
            read -s -r -p "Re-enter a archive password: " REPASS
            echo -n -e "\n"
            if [[ "$PASS" != "$REPASS" ]]; then
                print_error "Incorrect password error"
                exit 1
            fi
        fi
    fi

    if [[ -z $PASS ]]; then
        print_error "Empty password error"
        exit 1
    fi
}

# Print the names that exist in the directory: existing_items {dir} {name...}
function existing_items
{
    local dir=$1 name
    shift
    for name in "$@"; do
        if [[ -e $dir/$name ]]; then
            echo "$name"
        fi
    done
}

function write_backup_info
{
    {
        echo "DATE=$(date --iso-8601=seconds)"
        echo "MEDIAWIKI_IMAGE=$(service_image mediawiki)"
        echo "MARIADB_IMAGE=$(service_image mariadb)"
    } > "$1"
}

# Pack a tar stream into an encrypted archive: create_archive {archive} {tar args...}
# 7z does not keep file owners, so the tar stream carries them.
function create_archive
{
    local archive=$1
    shift

    tar -cf - "$@" | 7za a -bso0 -bsp0 -mhe=on -p"$PASS" -si"$(basename "$archive" .7z)" "$archive"
    local codes=("${PIPESTATUS[@]}")

    # tar exits with 1 when a file changed while it was being read
    if [[ ${codes[0]} -gt 1 || ${codes[1]} -ne 0 ]]; then
        rm -f "$archive"
        return 1
    fi
    if [[ ${codes[0]} -eq 1 ]]; then
        print_error "Some files changed while they were being archived"
    fi
    chmod 600 "$archive"

    # Record only the file name to check it anywhere: sha256sum -c {archive}.sha256
    if ! (cd "$(dirname "$archive")" && sha256sum "$(basename "$archive")") > "$archive.sha256"; then
        print_error "Checksum creation failed: '$archive.sha256'"
        rm -f "$archive.sha256"
        return 1
    fi
}

# Check {archive}.sha256 if it exists. Older backups have none.
function verify_checksum
{
    local archive=$1
    if [[ ! -f $archive.sha256 ]]; then
        print_error "Not found '$archive.sha256' file, skip the checksum"
        return 0
    fi
    (cd "$(dirname "$archive")" && sha256sum --quiet -c "$(basename "$archive").sha256")
}

# Extract an archive into a directory: extract_archive {archive} {dir}
# Supports '*.tar.7z' made by create_archive and the older plain 7z archives.
function extract_archive
{
    if [[ $1 == *.tar.7z ]]; then
        7za x -so -p"$PASS" "$1" | tar -xpf - -C "$2"
        local codes=("${PIPESTATUS[@]}")
        [[ ${codes[0]} -eq 0 && ${codes[1]} -eq 0 ]]
    else
        7za x -bso0 -bsp0 -y -p"$PASS" -o"$2" "$1"
    fi
}

function list_backups
{
    echo "List of backups:"
    find "$BACKUP_DIR" "$ROOT_DIR" -maxdepth 1 -type f -name '*.7z' -printf ' - %p\n' 2> /dev/null | sort
}
