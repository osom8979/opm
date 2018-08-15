#!/usr/bin/env bash

sudo usermod -aG docker $(whoami)

UPDATE_RESULT=`cat /etc/group | grep docker`
echo 'Group result:'
echo $UPDATE_RESULT
echo 'Done.'

