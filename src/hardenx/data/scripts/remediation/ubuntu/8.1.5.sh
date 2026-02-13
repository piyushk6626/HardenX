#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

DESIRED_STATE="$1"

if [[ "$DESIRED_STATE" == "Installed" ]]; then
    if apt-get install -y rsyslog &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
elif [[ "$DESIRED_STATE" == "Not Installed" ]]; then
    if apt-get purge -y rsyslog &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi