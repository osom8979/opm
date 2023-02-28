#!/usr/bin/env bash

if ! command -v git &> /dev/null; then
    echo "Not found git command" 1>&2
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "Not found curl command" 1>&2
    exit 1
fi

function md5_hash
{
    local val=$1
    if command -v md5 &> /dev/null; then
        # Darwin kernel
        echo -n "$val" | md5 -r | awk '{print $1}'
    elif command -v md5sum &> /dev/null; then
        echo -n "$val" | md5sum | awk '{print $1}'
    elif command -v openssl &> /dev/null; then
        echo -n "$val" | openssl md5 -r | awk '{print $1}'
    else
        echo "Unable to compute md5 checksum" 1>&2
        exit 1
    fi
}

if ! EMAIL=$(git config user.email); then
    read -r -p "Enter the your email address: " EMAIL
fi

LOWER_EMAIL=$(echo -n "$EMAIL" | tr '[:upper:]' '[:lower:]')
HASH=$(md5_hash "$LOWER_EMAIL")
SIZE=512
URL="https://www.gravatar.com/avatar/${HASH}?s=${SIZE}"
DEST=$HOME/.face

curl -o "$DEST" "$URL"
