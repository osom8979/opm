#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

DOMAIN=$1
EMAIL=$2

if [[ -z $DOMAIN || -z $EMAIL ]]; then
    echo "Usage: $0 {domain} {email}"
    exit 1
fi

echo "Domain: $DOMAIN"
echo "E-mail: $EMAIL"

STACK_NAME=traefik-stack
NET_NAME=traefik-net
NET_EXISTS=`docker network ls | grep traefik-net`

if [[ -z $NET_EXISTS ]]; then
    echo "Create $NET_NAME overlay network"
    docker network create -d overlay "$NET_NAME"
else
    echo "Exists $NET_NAME"
fi

OPT_DIR=/opt/traefik
TOML_DEST="$OPT_DIR/traefik.toml"
ACME_DEST="$OPT_DIR/acme.json"

if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

TOML_TEMPLATE=traefik-template.toml
COMPOSE_NAME=traefik-compose.yml

if [[ ! -f "$TOML_TEMPLATE" ]]; then
    echo "Not found $TOML_TEMPLATE file"
    exit 1
fi
if [[ ! -f "$COMPOSE_NAME" ]]; then
    echo "Not found $COMPOSE_NAME file"
    exit 1
fi

if [[ -f "$TOML_DEST" ]]; then
    echo "Exists $TOML_DEST file"
else
    echo "Create $TOML_DEST file"
    cat "$TOML_TEMPLATE" | sed -e "s/@DOMAIN_NAME@/$DOMAIN/g" -e "s/@EMAIL@/$EMAIL/g" > "$TOML_DEST"
fi

if [[ -f "$ACME_DEST" ]]; then
    echo "Exists $ACME_DEST file"
else
    echo "Create $ACME_DEST file"
    touch "$ACME_DEST" # && chmod 600 "$ACME_DEST"
fi

echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_NAME" "$STACK_NAME"

echo 'Done.'

