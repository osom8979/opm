#!/usr/bin/env bash

# See also:
# https://docs.docker.com/install/linux/docker-ce/ubuntu/

echo "Uninstall old versions ..."
sudo apt-get remove \
    docker \
    docker-engine \
    docker.io \
    containerd \
    runc

echo "Install prerequisites packages ..."
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

echo "Install using the repository ..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "Install Docker Engine - Community ..."
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

