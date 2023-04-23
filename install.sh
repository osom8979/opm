#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

USAGE="
Usage: ${BASH_SOURCE[0]} [options] [com1] [com2] ... [comN]

Available options are:
  -h, --help        Print this message
  -l, --list        List of components
  -u, --uninstall   Uninstall components
  -y, --yes         Automatic yes to prompts
  -f, --force       Skip validation
  -n, --dry-run     Don't actually do anything, just show what would be done
  --                Skip handling options
"

# [IMPORTANT]
# Accurate recognition of installation contents is important,
# Use the `--verbose` flag as the 'DEFAULT',
# which is common for command line programs.

INSTALL_DIR="$ROOT_DIR/etc/install.d"
FORCE=0
AUTOMATIC_YES=0
DRY_RUN=0
OPCODE="install"
COMPONENTS=()

function print_error
{
    # shellcheck disable=SC2145
    echo -e "\033[31m$@\033[0m" 1>&2
}

function print_warning
{
    # shellcheck disable=SC2145
    echo -e "\033[33m$@\033[0m"
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
    -u|--uninstall)
        OPCODE="uninstall"
        shift
        ;;
    -f|--force)
        FORCE=1
        shift
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

vfi_flags=(-v)
if [[ $FORCE -eq 1 ]]; then
    vfi_flags+=(-f)
fi
if [[ $AUTOMATIC_YES -eq 0 ]]; then
    vfi_flags+=(-i)
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
        if [[ $FORCE -eq 0 ]]; then
            exit 1
        else
            print_warning "[$index/$size] Forced to move on to the next step"
            continue
        fi
    fi

    if [[ $AUTOMATIC_YES -eq 0 ]]; then
        read -r -p "[$index/$size] $OPCODE '$cursor' ? (y/n) " yn
        case $yn in
            y|Y)
                ;;
            *)
                continue
                ;;
        esac
    fi

    if [[ $DRY_RUN -eq 0 ]]; then
        print_message "[$index/$size] Start ${OPCODE}ing '$cursor' ..."

        # shellcheck disable=SC1090
        OPM_HOME="$ROOT_DIR" \
        FORCE=$FORCE \
        AUTOMATIC_YES=$AUTOMATIC_YES \
        VFI_FLAGS="${vfi_flags[*]}" \
            "$SHELL" "$script" "$OPCODE"
    else
        print_message "[$index/$size] Dry-run ${OPCODE}ing '$cursor' ..."
    fi

    code=$?
    if [[ $code -ne 0 ]]; then
        print_error "[$index/$size] Failed to ${OPCODE} '$cursor'"
        if [[ $FORCE -eq 0 ]]; then
            exit $code
        else
            print_warning "[$index/$size] Forced to move on to the next step"
            continue
        fi
    fi
done
