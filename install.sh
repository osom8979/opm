#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

USAGE="
Usage: ${BASH_SOURCE[0]} [options] [com1] [com2] ... [comN]

Available options are:
  -h, --help     Print this message
  -l, --list     List of components
  -y, --yes      Automatic yes to prompts
  -n, --dry-run  Don't actually do anything, just show what would be done
  --             Skip handling options
"

INSTALL_DIR=$ROOT_DIR/etc/install.d
AUTOMATIC_YES=0
DRY_RUN=0
COMPONENTS=()

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

trap 'cancel_black' INT

function cancel_black
{
    print_error "An interrupt signal was detected."
    exit 1
}

function print_usage
{
    echo "$USAGE"
}

function print_component_names
{
    local name
    for cursor in "$INSTALL_DIR"/*.sh; do
        name=$(echo "$cursor" | sed -E 's/.*\/([^\/]+)\.sh$/\1/g')
        if [[ -n $name ]]; then
            echo "$name"
        fi
    done
}

function print_sorted_component_names
{
    print_component_names | sort
}

while [[ -n $1 ]]; do
    case $1 in
    -h|--help)
        print_usage
        exit 0
        ;;
    -l|--list)
        print_sorted_component_names
        exit 0
        ;;
    -y|--yes)
        AUTOMATIC_YES=1
        shift
        ;;
    -n|--dry-run)
        DRY_RUN=1
        shift
        ;;
    --)
        shift
        break
        ;;
    -*)
        print_error "Unknown option: $1"
        exit 1
        ;;
    *)
        COMPONENTS+=("$1")
        shift
        ;;
    esac
done

## ----------------
## Install software
## ----------------

if [[ "${#COMPONENTS[*]}" -eq 0 ]]; then
    mapfile -t COMPONENTS < <(print_sorted_component_names)
fi

size=${#COMPONENTS[*]}
index=0

for cursor in "${COMPONENTS[@]}"; do
    ((index++))

    script="$INSTALL_DIR/$cursor.sh"
    if [[ -f "$script" ]]; then
        print_message "[$index/$size] Found component script: '$script'"
    else
        print_error "[$index/$size] Not found component script: '$script'"
        exit 1
    fi

    if [[ $AUTOMATIC_YES -eq 0 ]]; then
        read -r -p "[$index/$size] Install '$cursor' ? (y/n) " yn
        case $yn in
            y|Y)
                ;;
            *)
                continue
                ;;
        esac
    fi

    if [[ $DRY_RUN -eq 0 ]]; then
        print_message "[$index/$size] Installing '$cursor' ..."
        # shellcheck disable=SC1090
        OPM_HOME=$ROOT_DIR "$SHELL" "$script"
    else
        print_message "[$index/$size] Dry-run installing '$cursor' ..."
    fi

    code=$?
    if [[ $code -ne 0 ]]; then
        print_error "[$index/$size] Failed to install '$cursor'"
        exit $code
    fi
done
