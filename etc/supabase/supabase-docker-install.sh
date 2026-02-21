#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
REPO_DIR="$SCRIPT_DIR/.supabase.repo"

if ! command -v git &> /dev/null; then
    echo "Not found git command" 1>&2
    exit 1
fi

# Get the code
git clone --depth 1 https://github.com/supabase/supabase "$REPO_DIR"

# Copy the compose files over to your project
cp -vrf "$REPO_DIR/docker" "$SCRIPT_DIR"

# Copy the fake env vars
cp -v "$REPO_DIR/docker/.env.example" "$SCRIPT_DIR/docker/.env"

# Remove original code
rm -vrf "$REPO_DIR"
