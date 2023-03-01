#!/usr/bin/env bash

PORTUS_FRONTEND_HOST=$1
REGISTRY_FRONTEND_HOST=$2
FRONTEND_SCHEMA=${3:-https}
if [[ -z $PORTUS_FRONTEND_HOST ]]; then
    echo "Usage: $0 {portus_host} {registry_host} {schema:https}"
    exit 1
fi

export PORTUS_FRONTEND_HOST
export REGISTRY_FRONTEND_HOST
export FRONTEND_SCHEMA
echo "Frontend Host: $PORTUS_FRONTEND_HOST"

if [[ $(id -u) -ne 0 ]]; then
    echo 'Please run as root.'
    exit 1
fi

OPT_DIR=/opt/opm/portus
if [[ -d "$OPT_DIR" ]]; then
    echo "Exists $OPT_DIR directory"
else
    echo "Create $OPT_DIR directory"
    mkdir -p "$OPT_DIR"
fi

OPT_CERTS=$OPT_DIR/certs
OPT_REGISTRY=$OPT_DIR/registry
OPT_DB=$OPT_DIR/db

if [[ ! -d "$OPT_CERTS" ]]; then
    mkdir -p "$OPT_CERTS"
fi
if [[ ! -d "$OPT_REGISTRY" ]]; then
    mkdir -p "$OPT_REGISTRY"
fi
if [[ ! -d "$OPT_DB" ]]; then
    mkdir -p "$OPT_DB"
fi

OPT_CERTS_KEY=$OPT_CERTS/portus.key
OPT_CERTS_CRT=$OPT_CERTS/portus.crt
if [[ -f "$OPT_CERTS_KEY" && -f "$OPT_CERTS_CRT" ]]; then
    echo "Exists crt/key files."
else
    openssl req -x509 -sha256 -nodes -days 36500 -newkey rsa:2048 \
        -keyout "$OPT_CERTS_KEY" \
        -out "$OPT_CERTS_CRT"
fi

#PORTUS_MINIO_ID_SECRET_NAME=portus-minio-id
#PORTUS_MINIO_ID_SECRET_VALUE=minio
#PORTUS_MINIO_ID_SECRET_EXISTS=`docker secret ls | grep $PORTUS_MINIO_ID_SECRET_NAME`
#if [[ -z $PORTUS_MINIO_ID_SECRET_EXISTS ]]; then
#    echo "$PORTUS_MINIO_ID_SECRET_VALUE" | docker secret create "$PORTUS_MINIO_ID_SECRET_NAME" -
#else
#    echo "Exists $PORTUS_MINIO_ID_SECRET_NAME"
#fi
#
#PORTUS_MINIO_PW_SECRET_NAME=portus-minio-pw
#PORTUS_MINIO_PW_SECRET_EXISTS=`docker secret ls | grep $PORTUS_MINIO_PW_SECRET_NAME`
#if [[ ! -z $PORTUS_MINIO_PW_SECRET_EXISTS ]]; then
#    echo "Exists ${PORTUS_MINIO_PW_SECRET_NAME}, remove it."
#    echo "You must remove the key to continue."
#    echo "Run this command:"
#    echo " docker secret rm $PORTUS_MINIO_PW_SECRET_NAME"
#    exit 1
#fi
#
#read -sp "Enter the docker-secret ($PORTUS_MINIO_PW_SECRET_NAME) password: " PORTUS_MINIO_PW_SECRET_VALUE
#echo -e "\nCreate $PORTUS_MINIO_PW_SECRET_NAME secret"
#echo "$PORTUS_MINIO_PW_SECRET_VALUE" | docker secret create "$PORTUS_MINIO_PW_SECRET_NAME" -

read -p "Enter the MinIO volume path: " MINIO_DATA_MOUNT_POINT
export MINIO_DATA_MOUNT_POINT
if [[ ! -d "$MINIO_DATA_MOUNT_POINT" ]]; then
    mkdir -p "$MINIO_DATA_MOUNT_POINT"
fi

#MINIO_BUCKET_NAME=docker-registry
#if [[ ! -d "$MINIO_DATA_MOUNT_POINT/$MINIO_BUCKET_NAME" ]]; then
#    mkdir -p "$MINIO_DATA_MOUNT_POINT/$MINIO_BUCKET_NAME"
#fi

REGISTRY_CONFIG_TEMPLATE=12-portus-registry-config.yml
REGISTRY_CONFIG_PATH="$OPT_REGISTRY/config.yml"
if [[ -f "$REGISTRY_CONFIG_PATH" ]]; then
    echo "Exists $REGISTRY_CONFIG_PATH file"
else
    echo "Create $REGISTRY_CONFIG_PATH file"

    ## ==[[ MinIO setting
    #cat "$REGISTRY_CONFIG_TEMPLATE" | sed \
    #    -e "s/@PORTUS_FRONTEND_HOST@/$PORTUS_FRONTEND_HOST/g" \
    #    -e "s/@REGISTRY_FRONTEND_HOST@/$REGISTRY_FRONTEND_HOST/g" \
    #    -e "s/@FRONTEND_SCHEMA@/$FRONTEND_SCHEMA/g" \
    #    -e "s/@PORTUS_MINIO_ID_SECRET_VALUE@/$PORTUS_MINIO_ID_SECRET_VALUE/g" \
    #    -e "s/@PORTUS_MINIO_PW_SECRET_VALUE@/$PORTUS_MINIO_PW_SECRET_VALUE/g" \
    #    -e "s/@MINIO_BUCKET_NAME@/$MINIO_BUCKET_NAME/g" \
    #    > "$REGISTRY_CONFIG_PATH"
    ## ]]==

    ## ==[[ Filesystem setting
    cat "$REGISTRY_CONFIG_TEMPLATE" | sed \
        -e "s/@PORTUS_FRONTEND_HOST@/$PORTUS_FRONTEND_HOST/g" \
        -e "s/@REGISTRY_FRONTEND_HOST@/$REGISTRY_FRONTEND_HOST/g" \
        -e "s/@FRONTEND_SCHEMA@/$FRONTEND_SCHEMA/g" \
        > "$REGISTRY_CONFIG_PATH"
    ## ]]==
fi

REGISTRY_INIT_SRC=12-portus-registry-init
REGISTRY_INIT_PATH="$OPT_REGISTRY/init"
if [[ -f "$REGISTRY_INIT_PATH" ]]; then
    echo "Exists $REGISTRY_INIT_PATH file"
else
    echo "Create $REGISTRY_INIT_PATH file"
    cp "$REGISTRY_INIT_SRC" "$REGISTRY_INIT_PATH"
fi

# Error compose settings:
#  command: mysqld --character-set-server=utf8 --collation-server=utf8_unicode_ci --init-connect='SET NAMES UTF8;' --innodb-flush-log-at-trx-commit=0
# Error message:
#  2020-03-20 05:42:21+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 1:10.4.12+maria~bionic started.
#  2020-03-20 05:42:21+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
#  2020-03-20 05:42:21+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 1:10.4.12+maria~bionic started.
#  2020-03-20 05:42:21+00:00 [Note] [Entrypoint]: Initializing database files
#  /usr/sbin/mysqld: Too many arguments (first extra is 'NAMES').
#  2020-03-20  5:42:22 0 [ERROR] Aborting
DB_CONFIG_SRC=12-portus-db-config
DB_CONFIG_PATH="$OPT_DB/portus.cnf"
if [[ -f "$DB_CONFIG_PATH" ]]; then
    echo "Exists $DB_CONFIG_PATH file"
else
    echo "Create $DB_CONFIG_PATH file"
    cp "$DB_CONFIG_SRC" "$DB_CONFIG_PATH"
fi

PORTUS_WEB_KEYBASE_SECRET_NAME=portus-web-keybase
PORTUS_WEB_KEYBASE_SECRET_EXISTS=`docker secret ls | grep $PORTUS_WEB_KEYBASE_SECRET_NAME`
if [[ -z $PORTUS_WEB_KEYBASE_SECRET_EXISTS ]]; then
    PORTUS_WEB_KEYBASE_SECRET_VALUE=`openssl rand -hex 64`
    echo "Generate keybase: $PORTUS_WEB_KEYBASE_SECRET_VALUE"
    echo "$PORTUS_WEB_KEYBASE_SECRET_VALUE" | docker secret create "$PORTUS_WEB_KEYBASE_SECRET_NAME" -
else
    echo "Exists $PORTUS_WEB_KEYBASE_SECRET_NAME"
fi

PORTUS_WEB_PW_SECRET_NAME=portus-web-pw
PORTUS_WEB_PW_SECRET_EXISTS=`docker secret ls | grep $PORTUS_WEB_PW_SECRET_NAME`
if [[ -z $PORTUS_WEB_PW_SECRET_EXISTS ]]; then
    read -sp "Enter the docker-secret ($PORTUS_WEB_PW_SECRET_NAME) password: " PORTUS_WEB_PW_SECRET_VALUE
    echo -e "\nCreate $PORTUS_WEB_PW_SECRET_NAME secret"
    echo "$PORTUS_WEB_PW_SECRET_VALUE" | docker secret create "$PORTUS_WEB_PW_SECRET_NAME" -
else
    echo "Exists $PORTUS_WEB_PW_SECRET_NAME"
fi

PORTUS_DB_PW_SECRET_NAME=portus-db-pw
PORTUS_DB_PW_SECRET_EXISTS=`docker secret ls | grep $PORTUS_DB_PW_SECRET_NAME`
if [[ -z $PORTUS_DB_PW_SECRET_EXISTS ]]; then
    read -sp "Enter the docker-secret ($PORTUS_DB_PW_SECRET_NAME) password: " PORTUS_DB_PW_SECRET_VALUE
    echo -e "\nCreate $PORTUS_DB_PW_SECRET_NAME secret"
    echo "$PORTUS_DB_PW_SECRET_VALUE" | docker secret create "$PORTUS_DB_PW_SECRET_NAME" -
else
    echo "Exists $PORTUS_DB_PW_SECRET_NAME"
fi

STACK_NAME=portus
COMPOSE_YML=12-portus-compose.yml
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"
CODE=$?

echo "Portus: $FRONTEND_SCHEMA://$PORTUS_FRONTEND_HOST and continue setting."
echo "Registry: $FRONTEND_SCHEMA://$REGISTRY_FRONTEND_HOST and continue setting."
echo "Done ($CODE)."

