#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    exit 1
fi

DESIRED_STATE="Not Installed"

if [[ "$1" == "${DESIRED_STATE}" ]]; then
    if apt-get purge -y nis &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
fi