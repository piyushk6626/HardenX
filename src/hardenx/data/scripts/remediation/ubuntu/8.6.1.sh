#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ "$1" == "Installed" ]]; then
    if apt-get install -y aide aide-common &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
elif [[ "$1" == "Not Installed" ]]; then
    if apt-get remove -y aide aide-common &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
    exit 1
fi