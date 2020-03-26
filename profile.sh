#!/usr/bin/env bash

PROFILE_SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`

if [[ -z $OPM_HOME ]]; then
# Not found OPM_HOME variable.
export OPM_HOME=$PROFILE_SCRIPT_DIR
fi

## Default shell configurations.
export PS1="\e[1m[\t]\e[0m \e[1m\e[32m\u@\h\e[0m:\e[1m\e[96m\w\e[0m\n\\$ "
export PATH=$OPM_HOME/bin:$PATH

if [[ -z $CLICOLOR ]]; then
export CLICOLOR=1
fi

if [[ -z $LSCOLORS ]]; then
export LSCOLORS=ExFxBxDxCxegedabagacad
fi

if [[ -z $LC_COLLATE ]]; then
export LC_COLLATE=ko_KR.UTF-8
fi

if [[ -z $EDITOR ]]; then
export EDITOR=vi
fi

if [[ -z $LC_ALL ]]; then
export LC_ALL=en_US.UTF-8
fi

if [[ -z $LANG ]]; then
export LANG=en_US.UTF-8
fi

## Warning: Don't use the quoting("...").
for cursor in $OPM_HOME/etc/profile.d/*.sh; do
    . $cursor
done

