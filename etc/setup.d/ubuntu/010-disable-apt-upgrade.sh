#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

CONF_PATH=/etc/apt/apt.conf.d/20auto-upgrades
CONF_KEY=APT::Periodic::Unattended-Upgrade
TEMP_SUFFIX=.tmp
CONF_TEMP_PATH=$CONF_PATH$TEMP_SUFFIX

if [[ ! -f "$CONF_PATH" ]]; then
    echo "Not found apt.conf file: '$CONF_PATH'" 1>&2
    exit 1
fi

if [[ -f "$CONF_TEMP_PATH" ]]; then
    echo "Temporary files exist in path '$CONF_TEMP_PATH'" 1>&2
    echo "Please remove it yourself" 1>&2
    exit 1
fi

sed --in-place=$TEMP_SUFFIX -E "s/^($CONF_KEY +)\"1\";$/\1\"0\";/" "$CONF_PATH"

if grep -q -E "^$CONF_KEY +\"0\";$" "$CONF_PATH"; then
    echo "Disabled auto-update settings: '$CONF_PATH'"
else
    echo "The settings don't seem to be applied" 1>&2
    echo "Please edit yourself: '$CONF_PATH'" 1>&2
    exit 1
fi

if [[ -f "$CONF_TEMP_PATH" ]]; then
    rm "$CONF_TEMP_PATH"
    echo "Removed the created temporary file: '$CONF_TEMP_PATH'"
else
    echo "No temporary files were created: '$CONF_TEMP_PATH'" 1>&2
    exit 1
fi
