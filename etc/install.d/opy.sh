#!/bin/bash

if [[ -z $OPM_HOME ]]; then
    echo 'Not defined OPM_HOME variable.'
    exit 1
fi

echo ''
echo '## Install default apt packages:'
echo ' sudo apt-get install make build-essential wget curl llvm'
echo ' sudo apt-get install libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev'
echo ' sudo apt-get install libncurses5-dev xz-utils tk-dev'
echo ''


