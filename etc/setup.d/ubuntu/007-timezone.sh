#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v hostnamectl &> /dev/null; then
    echo "Not found hostnamectl command" 1>&2
    exit 1
fi

if ! CURRENT_TIMEZONE=$(timedatectl -p Timezone --value show); then
    echo "The 'timedatectl' command occurred error code $?" 1>&2
    exit 1
fi

DEFAULT_TIMEZONE="Asia/Seoul"

echo "The current timezone is '$CURRENT_TIMEZONE'"
read -r -e -i "$DEFAULT_TIMEZONE" \
    -p "Please enter the timezone to change (Default: $DEFAULT_TIMEZONE): " \
    NEXT_TIMEZONE

timedatectl set-timezone "$NEXT_TIMEZONE"
