#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v ssh-keygen &> /dev/null; then
    echo "Not found ssh-keygen command" 1>&2
    exit 1
fi

SSH_DIR=$HOME/.ssh
PRIVATE_KEY="$SSH_DIR/id_rsa"
PUBLIC_KEY="$SSH_DIR/id_rsa.pub"
KNOWN_HOSTS="$SSH_DIR/known_hosts"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

if [[ ! -d "$SSH_DIR" ]]; then
    mkdir -vp "$SSH_DIR"
fi
if [[ ! -f "$KNOWN_HOSTS" ]]; then
    touch "$KNOWN_HOSTS"
fi
if [[ ! -f "$AUTHORIZED_KEYS" ]]; then
    touch "$AUTHORIZED_KEYS"
fi

if [[ ! -e "$SSH_DIR" ]]; then
    ssh-keygen -q -t rsa -N "" -f "$PRIVATE_KEY"
fi

if [[ -f "$PUBLIC_KEY" ]]; then
    cat "$PUBLIC_KEY"
fi
