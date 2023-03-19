#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Not found git executable" 1>&2
    exit 1
fi

git config --global credential.helper "$(opm-home)/bin/opy-git-credential"
