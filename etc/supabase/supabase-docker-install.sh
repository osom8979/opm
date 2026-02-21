#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
REPO_DIR="$ROOT_DIR/.supabase.repo"
DOCKER_DIR="$ROOT_DIR/docker"

if ! command -v git &> /dev/null; then
    echo "Not found git command" 1>&2
    exit 1
fi

# Get the code
git clone --depth 1 https://github.com/supabase/supabase "$REPO_DIR"

# Make your new supabase docker directory
if [[ ! -d "$DOCKER_DIR" ]]; then
    mkdir -vp "$DOCKER_DIR"
fi

# Copy the compose files over to your project
cp -vrf "$REPO_DIR/docker" "$DOCKER_DIR"

# Copy the fake env vars
cp -v "$REPO_DIR/docker/.env.example" "$DOCKER_DIR/.env"

# Remove original code
rm -vrf "$REPO_DIR"
