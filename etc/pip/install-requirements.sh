#!/bin/bash

REQUIREMENTS=requirements

if [[ ! -z $REQUIREMENTS ]]; then
    for cursor in $(cat "$REQUIREMENTS"); do
        echo "Install $cursor"
        sudo -H pip install $cursor
    done
else
    echo "Not found $REQUIREMENTS file."
fi

echo 'Done.'

