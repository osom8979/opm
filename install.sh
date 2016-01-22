#!/bin/bash

function getScriptDirectory {
    local working=$PWD
    cd "$(dirname "${BASH_SOURCE[0]}")"
    echo $PWD
    cd "$working"
}

WORKING=$PWD
SCRIPT_PATH=`getScriptDirectory`
INSTALL_DIR=$SCRIPT_PATH/etc/install.d

BASH_PROFILE_PATH=$HOME/.profile
if [[ ! -f "$BASH_PROFILE_PATH" ]]; then
BASH_PROFILE_PATH=$HOME/.bash_profile
fi

if [[ ! -z "$OPM_HOME" || ! -z $(cat "$BASH_PROFILE_PATH" | grep "OPM_HOME") ]]; then
    echo 'OPM_HOME variable is already the declared.'
else
    echo '## OSOM Common Script.'                   >> $BASH_PROFILE_PATH
    echo "export OPM_HOME=$SCRIPT_PATH"             >> $BASH_PROFILE_PATH
    echo 'if [[ -f "$OPM_HOME/profile.sh" ]]; then' >> $BASH_PROFILE_PATH
    echo '    . "$OPM_HOME/profile.sh"'             >> $BASH_PROFILE_PATH
    echo 'fi'                                       >> $BASH_PROFILE_PATH
    echo "Update $BASH_PROFILE_PATH file."
fi

if [[ -z "$OPM_HOME" ]]; then
OPM_HOME=$SCRIPT_PATH
fi

## -----------------
## Install software.
## -----------------

## Warning: Don't use the quoting("...").
for cursor in $INSTALL_DIR/*.sh; do
    echo "Install $cursor"
    source $cursor
    code=$?

    if [[ $code != 0 ]]; then
        echo '[WARNING] Install failure.'
    fi
done

echo 'Done.'

