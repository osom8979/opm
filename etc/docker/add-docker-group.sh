#!/usr/bin/env bash

sudo usermod -aG docker "$(whoami)"

echo "Group result: $(grep docker /etc/group)"
