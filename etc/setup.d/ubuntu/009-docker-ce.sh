#!/usr/bin/env bash

# https://docs.docker.com/engine/install/ubuntu/

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

if ! command -v apt &> /dev/null; then
    echo "Not found apt command" 1>&2
    exit 1
fi

sudo apt update
sudo apt install ca-certificates curl

# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install \
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
