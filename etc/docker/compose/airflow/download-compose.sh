#!/usr/bin/env bash
# https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

URL='https://airflow.apache.org/docs/apache-airflow/3.1.7/docker-compose.yaml'
OUTPUT="$ROOT_DIR/docker-compose.yaml"

curl -Lfo "$OUTPUT" "$URL"
