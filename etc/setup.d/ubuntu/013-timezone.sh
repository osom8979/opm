#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
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

echo "The current timezone is '$CURRENT_TIMEZONE'"
read -r -p "Please enter the timezone to change: " NEXT_TIMEZONE

timedatectl set-timezone "$NEXT_TIMEZONE"
