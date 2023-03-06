#!/usr/bin/env bash

if ! command -v hostnamectl &> /dev/null; then
    echo "Not found hostnamectl command" 1>&2
    exit 1
fi

if ! CURRENT_TIMEZONE=$(timedatectl -p Timezone --value show); then
    echo "An unknown error occurred on 'timedatectl' command" 1>&2
    exit 1
fi

echo "The current timezone is '$CURRENT_TIMEZONE'"
read -r -p "Please enter the timezone to change: " NEXT_TIMEZONE

timedatectl set-timezone "$NEXT_TIMEZONE"
