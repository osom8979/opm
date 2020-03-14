#!/usr/bin/env bash

sudo usermod -aG docker $(whoami)

echo 'Group result:' $(cat /etc/group | grep docker)

