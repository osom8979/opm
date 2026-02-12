#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

INSTALL_DIR=$HOME/.claude
SETTINGS_JSON=$INSTALL_DIR/settings.json
AGENTS_DIR=$INSTALL_DIR/agents

if [[ ! -d "$INSTALL_DIR" ]]; then
    mkdir -vp "$INSTALL_DIR"
fi

if [[ -e "$SETTINGS_JSON" ]]; then
    echo "The claude settings already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $SETTINGS_JSON" 1>&2
    exit 1
fi

if [[ -e "$AGENTS_DIR" ]]; then
    echo "The claude agents already exists" 1>&2
    echo "Delete the file to continue installation" 1>&2
    echo " $AGENTS_DIR" 1>&2
    exit 1
fi

ln -vs "$OPM_HOME/etc/claude/settings.json" "$SETTINGS_JSON"
ln -vs "$OPM_HOME/etc/claude/agents" "$AGENTS_DIR"
