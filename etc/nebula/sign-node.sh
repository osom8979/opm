#!/usr/bin/env bash

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

if ! command -v nebula-cert &> /dev/null; then
    echo "Not found nebula-cert command" 1>&2
    exit 1
fi

if [[ ! -f "$CURRENT_DIR/ca.crt" ]]; then
    echo "Not found ca.crt file" 1>&2
    exit 1
fi

if [[ ! -f "$CURRENT_DIR/ca.key" ]]; then
    echo "Not found ca.key file" 1>&2
    exit 1
fi

NODE_NAME=${1:-Node}
NODE_IP=${2:-192.168.100.1/24}
NODE_GROUPS=${3:-server,linux}

nebula-cert sign -name "$NODE_NAME" -ip "$NODE_IP" -groups "$NODE_GROUPS"

if [[ ! -f "$CURRENT_DIR/$NODE_NAME.crt" ]]; then
    echo "Not found $NODE_NAME.crt file" 1>&2
    exit 1
fi

if [[ ! -f "$CURRENT_DIR/$NODE_NAME.key" ]]; then
    echo "Not found $NODE_NAME.key file" 1>&2
    exit 1
fi
