#!/usr/bin/env bash

# https://docs.docker.com/engine/install/ubuntu/

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v apt-get &> /dev/null; then
    echo "Not found apt-get command" 1>&2
    exit 1
fi

echo "Uninstall old versions"
apt-get remove -y \
    docker \
    docker-engine \
    docker.io \
    containerd \
    runc

echo "Install required packages"
apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

KEYRINGS_DIR=/etc/apt/keyrings
if [[ ! -d "$KEYRINGS_DIR" ]]; then
    mkdir -vp "$KEYRINGS_DIR"
    chmod 0755 "$KEYRINGS_DIR"
fi

echo "Add Docker's official GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "Set up the repository"
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

if [[ -n $SUDO_USER ]]; then
    read -r -p "Add user '${SUDO_USER}' to 'docker' group? (y/N) " ANSWER
    if [[ "$ANSWER" =~ ^[yY]$ ]]; then
        usermod -aG docker "$SUDO_USER"
        newgrp docker
    fi
    echo "Group result: $(grep docker /etc/group)"
fi

if command -v systemctl &> /dev/null; then
    read -r -p "Restart docker service? (y/N) " ANSWER
    if [[ "$ANSWER" =~ ^[yY]$ ]]; then
        systemctl restart docker
    fi
fi
