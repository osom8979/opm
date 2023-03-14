#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v fwupdmgr &> /dev/null; then
    echo "Not found fwupdmgr command" 1>&2
    exit 1
fi

fwupdmgr refresh
fwupdmgr -y update
