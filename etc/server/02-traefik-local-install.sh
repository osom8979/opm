#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

if [[ -z $(which openssl) ]]; then
    echo "Not found openssl."
    exit 1
fi

OPT_DIR=/opt/opm/traefik-local
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

PUBLISH_PORT=10001
export PUBLISH_PORT

TOML_TEMPLATE=02-traefik-local-template.toml
TOML_PATH="$OPT_DIR/traefik.toml"
if [[ -f "$TOML_PATH" ]]; then
    echo "Exists $TOML_PATH file"
else
    echo "Not found $TOML_PATH file"

    LOCAL_DOMAIN=$1
    WEB_PORT=$2

    if [[ -z $LOCAL_DOMAIN ]]; then
        echo "Usage: $0 {local_domain} {publish_port:10001}"
        exit 1
    fi

    if [[ ! -z $WEB_PORT ]]; then
        PUBLISH_PORT=$WEB_PORT
    fi

    echo "Local Domain: $LOCAL_DOMAIN"
    echo "Create $TOML_PATH file"
    cat "$TOML_TEMPLATE" | sed -e "s/@LOCAL_DOMAIN@/$LOCAL_DOMAIN/g" > "$TOML_PATH"
fi

KEY_PATH=$OPT_DIR/traefik.key
CRT_PATH=$OPT_DIR/traefik.crt
if [[ -f "$KEY_PATH" && -f "$CRT_PATH" ]]; then
    echo "Exists $KEY_PATH & $CRT_PATH files"
else
    echo "Create key & crt"
    openssl req -subj '/CN=localhost' -x509 -newkey rsa:2048 -nodes -keyout "$KEY_PATH" -out "$CRT_PATH" -days 36500
fi

NET_NAME=traefik-local-net
NET_EXISTS=`docker network ls | grep $NET_NAME`
if [[ -z $NET_EXISTS ]]; then
    echo "Create $NET_NAME overlay network"
    docker network create -d overlay "$NET_NAME"
else
    echo "Exists $NET_NAME"
fi

STACK_NAME=traefik-local
COMPOSE_YML=02-traefik-local-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Traefik local web: https://localhost:$PUBLISH_PORT/"
echo "Done ($CODE)."

