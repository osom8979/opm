#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "Not found curl command" 1>&2
    exit 1
fi

curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
