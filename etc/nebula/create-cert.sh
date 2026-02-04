#!/usr/bin/env bash

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)

if ! command -v nebula-cert &> /dev/null; then
    echo "Not found nebula-cert command" 1>&2
    exit 1
fi

CA_NAME=${1:-opm}
CA_DURATION=${2:-87600h}  # 10 years = 10 * 365 * 24 hours = 87600 hours

nebula-cert ca -name "$CA_NAME" -duration "$CA_DURATION"

if [[ ! -f "$CURRENT_DIR/ca.crt" ]]; then
    echo "Not found ca.crt file" 1>&2
    exit 1
fi

if [[ ! -f "$CURRENT_DIR/ca.key" ]]; then
    echo "Not found ca.key file" 1>&2
    exit 1
fi
