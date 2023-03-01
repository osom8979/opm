#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

OPT_DIR=/opt/opm/postfix
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

MAIN_CF_TEMPLATE=01-postfix-main.cf
MAIN_CF_PATH="$OPT_DIR/main.cf"
if [[ -f "$MAIN_CF_PATH" ]]; then
    echo "Exists $MAIN_CF_PATH file"
else
    echo "Not found $MAIN_CF_PATH file"

    HOST_NAME=$1    # Host FQDN, e.g. email.site.com
    DOMAIN_NAME=$2  # Only domain, e.g. site.com
    if [[ -z $HOST_NAME || -z $DOMAIN_NAME ]]; then
        echo "Usage: $0 {host_name} {domain_name}"
        exit 1
    fi

    echo "Host name: $HOST_NAME"
    echo "Domain name: $DOMAIN_NAME"

    echo "Create $MAIN_CF_PATH file"
    cat "$MAIN_CF_TEMPLATE" | sed -e "s/@HOST_NAME@/$HOST_NAME/g" -e "s/@DOMAIN_NAME@/$DOMAIN_NAME/g" > "$MAIN_CF_PATH"
fi

NET_NAME=postfix-net
NET_EXISTS=`docker network ls | grep $NET_NAME`
if [[ -z $NET_EXISTS ]]; then
    echo "Create $NET_NAME overlay network"
    docker network create -d overlay "$NET_NAME"
else
    echo "Exists $NET_NAME"
fi

STACK_NAME=postfix
COMPOSE_YML=01-postfix-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Local Postfix network: $NET_NAME"
echo "Local Postfix host: ${STACK_NAME}_api"
echo "Done ($CODE)."

