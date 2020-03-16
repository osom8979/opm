#!/usr/bin/env bash

SCRIPT_DIR=`_cur="$PWD" ; cd "$(dirname "${BASH_SOURCE[0]}")" ; echo "$PWD" ; cd "$_cur"`
INSTALL_DIR=$SCRIPT_DIR/etc/install.d

if [[ -z $BASH_PROFILE_PATH ]]; then
    ## See INVOCATION in 'man bash'
    BASH_PROFILE_PATH="$HOME/.bashrc"
fi

if [[ ! -z "$OPM_HOME" || ! -z $(cat "$BASH_PROFILE_PATH" | grep "OPM_HOME") ]]; then
    echo 'OPM_HOME variable is already the declared.'
else
    echo '## OSOM Common Script.'                   >> $BASH_PROFILE_PATH
    echo "export OPM_HOME=$SCRIPT_DIR"              >> $BASH_PROFILE_PATH
    echo 'if [[ -f "$OPM_HOME/profile.sh" ]]; then' >> $BASH_PROFILE_PATH
    echo '    . "$OPM_HOME/profile.sh"'             >> $BASH_PROFILE_PATH
    echo 'fi'                                       >> $BASH_PROFILE_PATH
    echo "Update $BASH_PROFILE_PATH file."
fi

if [[ -z "$OPM_HOME" ]]; then
OPM_HOME=$SCRIPT_DIR
fi

## -----------------
## Install software.
## -----------------

## Warning: Don't use the quoting("...").
for cursor in $INSTALL_DIR/*.sh; do
    echo "Install $cursor"
    source $cursor

    if [[ $? -ne 0 ]]; then
        echo '[WARNING] Install failure.'
        exit 1
    fi
done

echo 'Done.'

