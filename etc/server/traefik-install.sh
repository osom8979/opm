#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

ACME_DOMAIN=$1
ACME_EMAIL=$2
if [[ -z $ACME_DOMAIN || -z $ACME_EMAIL ]]; then
    echo "Usage: $0 {acme_domain} {acme_email}"
    exit 1
fi

echo "ACME Domain: $ACME_DOMAIN"
echo "ACME E-mail: $ACME_EMAIL"

NET_NAME=traefik-net
NET_EXISTS=`docker network ls | grep $NET_NAME`
if [[ -z $NET_EXISTS ]]; then
    echo "Create $NET_NAME overlay network"
    docker network create -d overlay "$NET_NAME"
else
    echo "Exists $NET_NAME"
fi

TOML_TEMPLATE=traefik-template.toml
if [[ ! -f "$TOML_TEMPLATE" ]]; then
    echo "Not found $TOML_TEMPLATE file"
    exit 1
fi

COMPOSE_YML=traefik-compose.yml
if [[ ! -f "$COMPOSE_YML" ]]; then
    echo "Not found $COMPOSE_YML file"
    exit 1
fi

OPT_DIR=/opt/traefik
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

TOML_PATH="$OPT_DIR/traefik.toml"
if [[ -f "$TOML_PATH" ]]; then
    echo "Exists $TOML_PATH file"
else
    echo "Create $TOML_PATH file"
    cat "$TOML_TEMPLATE" | sed -e "s/@ACME_DOMAIN@/$ACME_DOMAIN/g" -e "s/@ACME_EMAIL@/$ACME_EMAIL/g" > "$TOML_PATH"
fi

ACME_PATH="$OPT_DIR/acme.json"
if [[ -f "$ACME_PATH" ]]; then
    echo "Exists $ACME_PATH file"
else
    echo "Create $ACME_PATH file"
    ## Error starting provider *acme.Provider: unable to get ACME account:
    ## permissions 644 for acme.json are too open, please use 600
    touch "$ACME_PATH" && chmod 600 "$ACME_PATH"
fi

STACK_NAME=traefik
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Done ($?)."

