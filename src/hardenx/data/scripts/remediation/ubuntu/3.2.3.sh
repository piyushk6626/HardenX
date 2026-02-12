#!/bin/bash

if [[ "$1" != "Not Installed" ]]; then
    echo "false"
    exit 1
fi

PACKAGE_NAME="talk"

if ! dpkg -s "$PACKAGE_NAME" &>/dev/null; then
    echo "true"
    exit 0
fi

if apt-get purge -y "$PACKAGE_NAME" &>/dev/null; then
    echo "true"
else
    echo "false"
fi