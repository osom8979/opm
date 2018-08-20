#!/usr/bin/env bash

function use_https {
    if [[ $(id -u) -ne 0 ]]; then
        echo 'Please run as root.'
        exit 1
    fi

    if [[ -z $(which openssl) ]]; then
        echo "Not found openssl."
        exit 1
    fi

    OPT_DIR=/opt/onlyoffice
    if [[ -d "$OPT_DIR" ]]; then
        echo "Exists $OPT_DIR directory"
    else
        echo "Create $OPT_DIR directory"
        mkdir -p "$OPT_DIR"
    fi

    CERTS_DIR=$OPT_DIR/certs
    if [[ -d "$CERTS_DIR" ]]; then
        echo "Exists $CERTS_DIR directory"
    else
        echo "Create $CERTS_DIR directory"
        mkdir -p "$CERTS_DIR"
    fi

    DAYS=36500 ## 100 years
    KEYSIZE=2048
    #KEYSIZE=4096
    PRIVATE_KEY_FILE=$CERTS_DIR/onlyoffice.key
    REQUEST_FILE=$CERTS_DIR/onlyoffice.csr
    CERTIFICATE_FILE=$CERTS_DIR/onlyoffice.crt
    DHPARAM_FILE=$CERTS_DIR/dhparam.pem

    COUNTRY=NO
    STATE=NO
    LOCATION=NO
    ORGANIZATION=NO
    ORGANIZATIONAL_UNIT=NO
    COMMON_NAME=NO

    ## sets certificate subject
    SUBJ="/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${ORGANIZATIONAL_UNIT}/CN=${COMMON_NAME}"

    ## Create the server private key
    openssl genrsa -out "$PRIVATE_KEY_FILE" $KEYSIZE

    ## Create the certificate signing request (CSR)
    openssl req -new -sha256 -key "$PRIVATE_KEY_FILE" -out "$REQUEST_FILE" -subj "${SUBJ}"

    ## Sign the certificate using the private key and CSR
    openssl x509 -req -sha256 -days $DAYS -in "$REQUEST_FILE" -signkey "$PRIVATE_KEY_FILE" -out "$CERTIFICATE_FILE"

    ## Check a certificate.
    openssl x509 -in "$CERTIFICATE_FILE" -text -noout

    ## Strengthening the server security
    openssl dhparam -out "$DHPARAM_FILE" 2048

    chmod 400 "$PRIVATE_KEY_FILE"
}

#use_https

NET_NAME=onlyoffice-net
NET_EXISTS=`docker network ls | grep $NET_NAME`
if [[ -z $NET_EXISTS ]]; then
    echo "Create $NET_NAME overlay network"
    docker network create -d overlay "$NET_NAME"
else
    echo "Exists $NET_NAME"
fi

STACK_NAME=onlyoffice
COMPOSE_YML=onlyoffice-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Done ($?)."

