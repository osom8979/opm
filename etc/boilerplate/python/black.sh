#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

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

ARGS=(
    "--check"
    "--diff"
    "--color"
    "--exclude=(/\.git|/\.venv)"
)

print_message "black ${ARGS[*]}"

"$ROOT_DIR/python" -m black "${ARGS[@]}" \
    "$ROOT_DIR/%PROJECT_LOWER%/" \
    "$ROOT_DIR/tester/" \
    "$ROOT_DIR/setup.py"
