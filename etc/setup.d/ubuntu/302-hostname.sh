#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v hostname &> /dev/null; then
    echo "Not found hostname command" 1>&2
    exit 1
fi

if ! command -v hostnamectl &> /dev/null; then
    echo "Not found hostnamectl command" 1>&2
    exit 1
fi

if ! CURRENT_HOSTNAME=$(hostname); then
    echo "The 'hostname' command occurred error code $?" 1>&2
    exit 1
fi

echo "The current hostname is '$CURRENT_HOSTNAME'"
read -r -p "Please enter the hostname to change: " NEXT_HOSTNAME

sudo hostnamectl set-hostname "$NEXT_HOSTNAME"
