#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

if [[ -z $OPM_HOME ]]; then
export OPM_HOME="$ROOT_DIR"
fi

if [[ -d "$OPM_HOME/bin" ]]; then
export PATH=$OPM_HOME/bin:$PATH
fi

if [[ -d "$OPM_HOME/include" ]]; then
export CPATH=$OPM_HOME/include:$CPATH
fi

if [[ -d "$OPM_HOME/lib" ]]; then
export LIBRARY_PATH=$OPM_HOME/lib:$LIBRARY_PATH
fi

if [[ -d "$OPM_HOME/lib/pkgconfig" ]]; then
export PKG_CONFIG_PATH=$OPM_HOME/lib/pkgconfig:$PKG_CONFIG_PATH
fi

if [[ -z $CLICOLOR ]]; then
export CLICOLOR=1
fi

if [[ -z $LSCOLORS ]]; then
export LSCOLORS=ExFxBxDxCxegedabagacad
fi

if [[ -z $LC_ALL ]]; then
export LC_ALL=en_US.UTF-8
fi

if [[ -z $LANG ]]; then
export LANG=en_US.UTF-8
fi

WHICH_NVIM=$(command -v nvim &> /dev/null)
WHICH_VIM=$(command -v vim &> /dev/null)
WHICH_VI=$(command -v vi &> /dev/null)

if [[ -z "$EDITOR" ]]; then
    if [[ -n "$WHICH_NVIM" ]]; then
        export EDITOR=$WHICH_NVIM
    elif [[ -n "$WHICH_VIM" ]]; then
        export EDITOR=$WHICH_VIM
    elif [[ -n "$WHICH_VI" ]]; then
        export EDITOR=$WHICH_VI
    fi
fi

for cursor in "$OPM_HOME/etc/profile.d"/*.sh; do
    # shellcheck disable=SC1090
    source "$cursor"
done
