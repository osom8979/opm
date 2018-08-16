#!/usr/bin/env bash

FRONTEND_HOST=$1
if [[ -z $FRONTEND_HOST ]]; then
    echo "Usage: $0 {frontend_host}"
    exit 1
fi

export FRONTEND_HOST
echo "Frontend Host: $FRONTEND_HOST"

SECRET_NAME=nextcloud-clouduser-pw
SECRET_EXISTS=`docker secret ls | grep $SECRET_NAME`
if [[ -z $SECRET_EXISTS ]]; then
    read -sp "Enter the docker-secret ($SECRET_NAME) password: " WIKIUSER_PW
    echo -e "\nCreate $SECRET_NAME secret"
    echo "$WIKIUSER_PW" | docker secret create "$SECRET_NAME" -
else
    echo "Exists $SECRET_NAME"
fi

COMPOSE_YML=nextcloud-compose.yml
if [[ ! -f "$COMPOSE_YML" ]]; then
    echo "Not found $COMPOSE_YML file"
    exit 1
fi

STACK_NAME=nextcloud
echo "Deploy stack: $STACK_NAME"
docker stack deploy -c "$COMPOSE_YML" "$STACK_NAME"

echo "Go to page $FRONTEND_HOST and continue setting."
echo "  Database type: MySQL"
echo "  Database host: nextcloud_db"
echo "  Database name: nextcloud"
echo "  Database username: clouduser"
echo "Done ($?)."

