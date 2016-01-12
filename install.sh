#!/bin/bash

CLEAN_FLAG=false

ARG_INDEX=1
ARG_SIZE=$#

while [[ $ARG_INDEX -le $ARG_SIZE ]]; do
    case $1 in
    --clean)
        CLEAN_FLAG=true
        ;;
    esac

    let 'ARG_INDEX = ARG_INDEX + 1'
    shift
done

function getScriptDirectory {
    local working=$PWD
    cd "$(dirname "${BASH_SOURCE[0]}")"
    echo $PWD
    cd "$working"
}

WORKING=$PWD
SCRIPT_PATH=`getScriptDirectory`

INSTALL_DIR=$SCRIPT_PATH/etc/install.d
PROFILE_PATH=$SCRIPT_PATH/profile
PROPERTY_PATH=$SCRIPT_PATH/property
INSTALL_NAME=INSTALL
USE_COLOR=true

BASH_PROFILE_PATH=$HOME/.profile
if [[ ! -f "$BASH_PROFILE_PATH" ]]; then
BASH_PROFILE_PATH=$HOME/.bash_profile
fi

## x86 or xx86_64
MACHINE_NAME=`uname -m`

## Darwin or Linux
KERNEL_NAME=`uname -s`

## --------
## Methods.
## --------

function stdout {
    echo $@
}

function stderr {
    if [[ $KERNEL_NAME == Linux && $USER_COLOR == true ]]; then
        echo -e "\e[31m$@\e[0m" 1>&2
    else
        echo "$@" 1>&2
    fi
}

function exists {
    local list=$1
    local name=$2
    local check=`echo $list | egrep "(:|^)$name(:|$)"`

    if [[ -z $check ]]; then
        echo 'false'
    else
        echo 'true'
    fi
}

## ---------------
## Update OPM Env.
## ---------------

if [[ ! -z "$OPM_HOME" || ! -z $(cat "$BASH_PROFILE_PATH" | grep "OPM_HOME") ]]; then
    stderr '[WARNING] OPM_HOME variable is already the declared.'
else
    echo '## OSOM Common Script.'                   >> $BASH_PROFILE_PATH
    echo "export OPM_HOME=$SCRIPT_PATH"             >> $BASH_PROFILE_PATH
    echo 'if [[ -f "$OPM_HOME/profile.sh" ]]; then' >> $BASH_PROFILE_PATH
    echo '    . "$OPM_HOME/profile.sh"'             >> $BASH_PROFILE_PATH
    echo 'fi'                                       >> $BASH_PROFILE_PATH
    stdout "Update $BASH_PROFILE_PATH file."
fi

if [[ -z "$OPM_HOME" ]]; then
OPM_HOME=$SCRIPT_PATH
fi

## -----------------
## Install software.
## -----------------

if [[ ! -f "$PROPERTY_PATH" || -z $(cat "$PROPERTY_PATH" | grep "$INSTALL_NAME") ]]; then
    echo "$INSTALL_NAME=" >> $PROPERTY_PATH
fi

INSTALL_LIST=`cat "$PROPERTY_PATH" | grep "$INSTALL_NAME" | sed "s/^$INSTALL_NAME=//g"`

if [[ $KERNEL_NAME == Darwin ]]; then
IN_PLACE_FLAG="-i .tmp"
else
IN_PLACE_FLAG="-i"
fi

## Warning: Don't use the quoting("...").
for cursor in $INSTALL_DIR/*.sh; do
    filename=${cursor##*/}
    check=`exists $INSTALL_LIST $filename`

    if [[ $CLEAN_FLAG == true && $check == true ]]; then
        ## CLEAN PROCESS:
        stdout 'Remove:' $cursor
        source $cursor --clean
        code=$?

        if [[ $code == 0 ]]; then
            sed $IN_PLACE_FLAG "s/:$filename//g" $PROPERTY_PATH
            stdout 'Remove success.'
        else
            stderr '[ERROR] Remove failure.'
        fi
    elif [[ $CLEAN_FLAG == false && $check == false ]]; then
        ## INSTALL PROCESS:
        stdout 'Install:' $cursor
        source $cursor
        code=$?

        if [[ $code == 0 ]]; then
            sed $IN_PLACE_FLAG "s/\(^$INSTALL_NAME=.*\)\$/\1:$filename/g" $PROPERTY_PATH
            stdout 'Install success.'
        else
            stderr '[ERROR] Install failure.'
        fi
    else
        ## UNKNOWN PROCESS:
        stdout 'Skip' $cursor
    fi
done

stdout 'Done.'

