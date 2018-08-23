#!/usr/bin/env bash 

#if [[ $(id -u) -ne 0 ]]; then
#    echo 'Please run as root.'
#    exit 1
#fi
#
#if [[ -z $(which openssl) ]]; then
#    echo "Not found openssl."
#    exit 1
#fi
#
#OPT_DIR=/opt/onlyoffice
#if [[ -d "$OPT_DIR" ]]; then
#    echo "Exists $OPT_DIR directory"
#else
#    echo "Create $OPT_DIR directory"
#    mkdir -p "$OPT_DIR"
#fi
#
#PROXY_TEMPLATE=onlyoffice-proxy.conf
#PROXY_PATH=$OPT_DIR/proxy_ssl.conf
#if [[ -f "$PROXY_PATH" ]]; then
#    echo "Exists $PROXY_PATH file"
#else
#    echo "Create $PROXY_PATH file"
#    cp "$PROXY_TEMPLATE" "$PROXY_PATH"
#fi
#
#CERTS_DIR=$OPT_DIR/certs
#if [[ -d "$CERTS_DIR" ]]; then
#    echo "Exists $CERTS_DIR directory"
#else
#    echo "Create $CERTS_DIR directory"
#    mkdir -p "$CERTS_DIR"
#fi
#
#PRIVATE_KEY_FILE=$CERTS_DIR/onlyoffice.key
#if [[ -f "$PRIVATE_KEY_FILE" ]]; then
#    echo "Exists $PRIVATE_KEY_FILE file"
#else
#    KEYSIZE=2048
#    #KEYSIZE=4096
#
#    echo "Create the server private key: $PRIVATE_KEY_FILE"
#    openssl genrsa -out "$PRIVATE_KEY_FILE" $KEYSIZE
#    chmod 400 "$PRIVATE_KEY_FILE"
#fi
#
#REQUEST_FILE=$CERTS_DIR/onlyoffice.csr
#if [[ -f "$REQUEST_FILE" ]]; then
#    echo "Exists $REQUEST_FILE file"
#else
#    COUNTRY=NO
#    STATE=NO
#    LOCATION=NO
#    ORGANIZATION=NO
#    ORGANIZATIONAL_UNIT=NO
#    COMMON_NAME=NO
#    SUBJ="/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${ORGANIZATIONAL_UNIT}/CN=${COMMON_NAME}"
#
#    echo "Create the certificate signing request (CSR): $REQUEST_FILE"
#    openssl req -new -sha256 -key "$PRIVATE_KEY_FILE" -out "$REQUEST_FILE" -subj "${SUBJ}"
#fi
#
#CERTIFICATE_FILE=$CERTS_DIR/onlyoffice.crt
#if [[ -f "$CERTIFICATE_FILE" ]]; then
#    echo "Exists $CERTIFICATE_FILE file"
#else
#    DAYS=36500 ## 100 years
#
#    echo "Sign the certificate using the private key and CSR: $CERTIFICATE_FILE"
#    openssl x509 -req -sha256 -days $DAYS -in "$REQUEST_FILE" -signkey "$PRIVATE_KEY_FILE" -out "$CERTIFICATE_FILE"
#
#    echo "Check a certificate."
#    openssl x509 -in "$CERTIFICATE_FILE" -text -noout
#fi
#
#DHPARAM_FILE=$CERTS_DIR/dhparam.pem
#if [[ -f "$DHPARAM_FILE" ]]; then
#    echo "Exists $DHPARAM_FILE file"
#else
#    echo "Strengthening the server security: $DHPARAM_FILE"
#    openssl dhparam -out "$DHPARAM_FILE" 2048
#fi
#
#NET_NAME=onlyoffice-net
#NET_EXISTS=`docker network ls | grep $NET_NAME`
#if [[ -z $NET_EXISTS ]]; then
#    echo "Create $NET_NAME overlay network"
#    docker network create -d overlay "$NET_NAME"
#else
#    echo "Exists $NET_NAME"
#fi

FRONTEND_HOST=$1
if [[ -z $FRONTEND_HOST ]]; then
    echo "Usage: $0 {frontend_host}"
    exit 1
fi

export FRONTEND_HOST
echo "Frontend Host: $FRONTEND_HOST"

STACK_NAME=onlyoffice
COMPOSE_YML=onlyoffice-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Document server host: https://${STACK_NAME}_api"
echo "Done ($?)."

