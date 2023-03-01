#!/usr/bin/env bash

if ! command -v hostnamectl &> /dev/null; then
    echo "Not found hostnamectl command" 1>&2
    exit 1
fi

sudo hostnamectl set-hostname jumpto
