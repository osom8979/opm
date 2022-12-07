#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
BOILERPLATE_DIR=$ROOT_DIR

VERBOSE=0

USAGE="
Usage: ${BASH_SOURCE[0]} [options] src dest

Available options are:
  -h, --help        Print this message.
  -l, --list        Print the source list.
  -v, --verbose     Be more verbose/talkative during the operation
  --                Stop handling options.
"

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

function print_verbose
{
    if [[ $VERBOSE -ne 0 ]]; then
        # shellcheck disable=SC2145
        echo -e "\033[32m$@\033[0m"
    fi
}

function print_usage
{
    echo "$USAGE"
}

trap 'cancel_black' INT

function cancel_black
{
    print_error "An interrupt signal was detected."
    exit 1
}

while [[ -n $1 ]]; do
    case $1 in
    -h|--help)
        print_usage
        exit 0
        ;;
    -l|--list)
        find "$BOILERPLATE_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%P\n'
        exit 0
        ;;
    -v|--verbose)
        VERBOSE=1
        shift
        ;;
    --)
        shift
        break
        ;;
    *)
        break
        ;;
    esac
done

if [[ -z "$1" ]]; then
    print_error "Empty 'src' argument"
    exit 1
fi
if [[ -z "$2" ]]; then
    print_error "Empty 'dest' argument"
    exit 1
fi

SOURCE_NAME=$1
DESTINATION_DIR=$2
shift 2

SOURCE_DIR=$ROOT_DIR/$SOURCE_NAME
if [[ ! -d "$SOURCE_DIR" ]]; then
    print_error "Not found source directory: $SOURCE_NAME"
    exit 1
fi

read -r -p 'Project name? ' PROJECT_NAME
read -r -p 'Project description? (Do not use quotation marks) ' PROJECT_DESC
read -r -p 'User name? ' USER_NAME
read -r -p 'User e-mail? ' USER_EMAIL
read -r -p 'Github ID? ' GITHUB_ID
PROJECT_LOWER=$(echo "${PROJECT_NAME,,}" | sed -e 's/[^a-zA-Z0-9]/_/g')
YEAR=$(date +%Y)

print_verbose "Year: $YEAR"
print_verbose "Project lower: $PROJECT_LOWER"
print_verbose "Source directory: $SOURCE_DIR"
print_verbose "Destination directory: $DESTINATION_DIR"

SED_ARGS=(
    -e "s/%PROJECT_NAME%/$PROJECT_NAME/g"
    -e "s/%PROJECT_LOWER%/$PROJECT_LOWER/g"
    -e "s/%PROJECT_DESC%/$PROJECT_DESC/g"
    -e "s/%USER_NAME%/$USER_NAME/g"
    -e "s/%USER_EMAIL%/$USER_EMAIL/g"
    -e "s/%GITHUB_ID%/$GITHUB_ID/g"
    -e "s/%YEAR%/$YEAR/g"
)

read -r -p "Are you sure you want to continue with the installation? (y/n) " YN
if [[ "${YN,,}" != 'y' ]]; then
    print_error "The job has been canceled"
    exit 1
fi

if [[ ! -d "$DESTINATION_DIR" ]]; then
    mkdir -p -v "$DESTINATION_DIR"
fi

function install_file
{
    local src=$1
    local dest=$2
    local src_filename=$3

    local dest_filename
    dest_filename=$(echo "$src_filename" | sed "${SED_ARGS[@]}")

    local lh="$working_dir/$src_filename"
    local rh="$target_dir/$dest_filename"

    sed "${SED_ARGS[@]}" "$lh" > "$rh"
    chmod $(stat -c '%a' "$lh") "$rh"
    print_verbose "Install file: '$lh' > '$rh'"
}

function install_dir
{
    local working_dir=$1
    local target_dir=$2
    local dirs
    local files

    print_verbose "Change source directory: $working_dir"
    print_verbose "Change target directory: $target_dir"

    mapfile -t dirs < <(find "$working_dir" -mindepth 1 -maxdepth 1 -type d -printf '%P\n')
    mapfile -t files < <(find "$working_dir" -mindepth 1 -maxdepth 1 -type f -printf '%P\n')

    local dest_dir

    for dir in "${dirs[@]}"; do
        dest_dir=$(echo "$dir" | sed "${SED_ARGS[@]}")

        mkdir -p "$target_dir/$dest_dir"
        print_verbose "Make directory: $target_dir/$dest_dir"

        install_dir "$working_dir/$dir" "$target_dir/$dest_dir"
    done

    for file in "${files[@]}"; do
        install_file "$working_dir" "$target_dir" "$file"
    done
}

install_dir "$SOURCE_DIR" "$DESTINATION_DIR"
print_message "Installation is complete"

