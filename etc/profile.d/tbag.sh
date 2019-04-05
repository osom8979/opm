#!/usr/bin/env bash

if [[ ! -z $TBAG_HOME ]]; then
    return 0
fi

if [[ -z $OPM_PROJECT ]]; then
    # Not found OPM_PROJECT variable.
    # But, not error.
    return 0
fi

TBAG_HOME=$OPM_PROJECT/tbag
export TBAG_HOME

