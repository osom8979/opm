#!/bin/bash

GET_PIP_NAME='get-pip.py'
LOCAL_GET_PIP_SCRIPT=`ls get-pip*.py`
GET_PIP_URL='https://bootstrap.pypa.io/get-pip.py'

curl --output $GET_PIP_NAME $GET_PIP_URL

CURL_EXIT_CODE=$?

if [[ $CURL_EXIT_CODE == 0 ]]; then
    USE_GET_PIP_SCRIPT=$GET_PIP_NAME
else
    echo "curl error ($CURL_EXIT_CODE)."
    USE_GET_PIP_SCRIPT=$LOCAL_GET_PIP_SCRIPT
fi

echo "Use the $USE_GET_PIP_SCRIPT file."
python "$USE_GET_PIP_SCRIPT"

if [[ -f $GET_PIP_NAME ]]; then
    echo "Remove $GET_PIP_NAME"
    rm $GET_PIP_NAME
fi

