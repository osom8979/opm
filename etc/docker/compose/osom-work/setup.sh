#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
ENV_PATH=$ROOT_DIR/.env

if [[ -f $ENV_PATH ]]; then
    echo "Exists '$ENV_PATH' file" 1>&2
    exit 1
fi

read -r -p "Enter the host (e.g. master.example.com): " FRONTEND_HOST
read -r -p "Enter the ACME email: " ACME_EMAIL
read -r -p "Enter the broker URL: " BROKER_URL

ENV="
FRONTEND_HOST=$FRONTEND_HOST
ACME_EMAIL=$ACME_EMAIL
BROKER_URL=$BROKER_URL
"

echo "$ENV" | sed '/^$/d' > "$ENV_PATH"
echo "Done."
