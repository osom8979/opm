#!/usr/bin/env bash

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

function tmux_get()
{
    local option=$1
    local default=$2

    local value
    if value="$(tmux show -gqv "$option")"; then
        if [[ -n "$value" ]]; then
            echo "$value"
        fi
    fi

    echo "$default"
}

function tmux_set()
{
    local option=$1
    local value=$2
    tmux set-option -gq "$option" "$value"
}
