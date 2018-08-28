#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

if [[ -z $(which openssl) ]]; then
    echo "Not found openssl."
    exit 1
fi

OPT_DIR=/opt/opm/traefik
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

LOG_DIR=$OPT_DIR/log
if [[ -d "$LOG_DIR" ]]; then
    echo "Exists $LOG_DIR directory"
else
    echo "Create $LOG_DIR directory"
    mkdir -p "$LOG_DIR"
fi

ACME_PATH=$OPT_DIR/acme.json
if [[ -f "$ACME_PATH" ]]; then
    echo "Exists $ACME_PATH file"
else
    echo "Create $ACME_PATH file"
    ## Error starting provider *acme.Provider: unable to get ACME account:
    ## permissions 644 for acme.json are too open, please use 600
    touch "$ACME_PATH" && chmod 600 "$ACME_PATH"
fi

PUBLISH_PORT=10000
export PUBLISH_PORT

TOML_TEMPLATE=00-traefik-template.toml
TOML_PATH="$OPT_DIR/traefik.toml"
if [[ -f "$TOML_PATH" ]]; then
    echo "Exists $TOML_PATH file"
else
    echo "Not found $TOML_PATH file"

    ACME_DOMAIN=$1
    ACME_EMAIL=$2
    WEB_PORT=$3

    if [[ -z $ACME_DOMAIN || -z $ACME_EMAIL ]]; then
        echo "Usage: $0 {acme_domain} {acme_email} {publish_port:10000}"
        exit 1
    fi

    if [[ ! -z $WEB_PORT ]]; then
        PUBLISH_PORT=$WEB_PORT
    fi

    echo "ACME Domain: $ACME_DOMAIN"
    echo "ACME E-mail: $ACME_EMAIL"

    echo "Create $TOML_PATH file"
    cat "$TOML_TEMPLATE" | sed -e "s/@ACME_DOMAIN@/$ACME_DOMAIN/g" -e "s/@ACME_EMAIL@/$ACME_EMAIL/g" > "$TOML_PATH"
fi

KEY_PATH=$OPT_DIR/traefik.key
CRT_PATH=$OPT_DIR/traefik.crt
if [[ -f "$KEY_PATH" && -f "$CRT_PATH" ]]; then
    echo "Exists $KEY_PATH & $CRT_PATH files"
else
    echo "Create key & crt"
    openssl req -subj '/CN=localhost' -x509 -newkey rsa:4096 -nodes -keyout "$KEY_PATH" -out "$CRT_PATH" -days 36500
fi

NET_NAME=traefik-net
NET_EXISTS=`docker network ls | grep $NET_NAME`
if [[ -z $NET_EXISTS ]]; then
    echo "Create $NET_NAME overlay network"
    docker network create -d overlay "$NET_NAME"
else
    echo "Exists $NET_NAME"
fi

STACK_NAME=traefik
COMPOSE_YML=00-traefik-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Traefik web: http://localhost:$PUBLISH_PORT/"
echo "Done ($CODE)."

