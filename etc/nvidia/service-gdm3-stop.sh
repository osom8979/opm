#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v service &> /dev/null; then
    echo "Not found service command" 1>&2
    exit 1
fi

service gdm3 stop
