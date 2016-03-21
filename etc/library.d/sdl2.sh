#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

OPM_LOCAL=$OPM_HOME/local
OPM_TMP=$OPM_HOME/tmp

## Don't remove DEPENDENCIES variable.
DEPENDENCIES=

NAME='SDL2-2.0.4'
URL='https://www.libsdl.org/release/SDL2-2.0.4.tar.gz'
MD5='44fc4a023349933e7f5d7a582f7b886e'

#NAME='SDL-2.0.4-10002'
#URL='https://www.libsdl.org/tmp/SDL-2.0.4-10002.tar.gz'
#MD5='32a23f12e8d9436a0fc6d12b5e8ad05f'

TEMP_DIR="$OPM_TMP/build"
DEST_NAME="$NAME.tar.gz"
WORK_NAME="$NAME"
ALREADY="$OPM_LOCAL/lib/libSDL2.a"
LOG_PATH="$TEMP_DIR/$NAME-`datetime`.log"
THREAD_FLAG=`thread-flag`

function runCommon {
    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$OPM_LOCAL >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

function runMacOSX {
    code=$?; [[ $code != 0 ]] && exit $code
    ./configure --prefix=$OPM_LOCAL >> $LOG_PATH

    code=$?; [[ $code != 0 ]] && exit $code
    make >> $LOG_PATH

    ## --------
    ## bug-fix: in the install-hdrs target,
    ##
    ## for file in $(HDRS) $(SDLTEST_HDRS); do \
    ##     $(INSTALL) -m 644 $(srcdir)/include/$$file $(DESTDIR)$(includedir)/SDL2/$$file; \
    ## done
    ## --------

    ## find install-hdrs target.
    local install_hdrs=`egrep -nA10 '^install-hdrs:.*' Makefile`
    local error_line=`echo "$install_hdrs" | grep 'for file in $(HDRS) $(SDLTEST_HDRS)'`
    local error_number=`echo "$error_line" | awk -F'-' '{print($1);}'`
    local condition='True'

    # remove error code.
    while [[ $condition == 'True' ]]; do
        local is_more=`sed -n "${error_number}p" Makefile | egrep '.*\\$'`
        if [[ "$is_more" == "" ]]; then
            condition='False'
        fi
        sed -i '.tmp' "${error_number}d" Makefile
    done

    # install header files.
    local header_dir="$OPM_LOCAL/include/SDL2"
    if [[ ! -d "$header_dir" ]]; then
        mkdir -p "$header_dir"
    fi
    cp -r include/*.h "$header_dir"

    code=$?; [[ $code != 0 ]] && exit $code
    make install >> $LOG_PATH
}

LINUX_FUNC=runCommon
MACOSX_FUNC=runMacOSX
WINDOWS_FUNC=runCommon

. general-build "$NAME" "$URL" "$MD5" "$TEMP_DIR"    \
    "$DEST_NAME" "$WORK_NAME" "$ALREADY" "$LOG_PATH" \
    "$LINUX_FUNC" "$MACOSX_FUNC" "$WINDOWS_FUNC"     \
    "$DEPENDENCIES"

