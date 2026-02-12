#!/bin/bash

if [[ $# -ne 1 || $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

DESIRED_STATE="$1"
PACKAGE_NAME="ftp"

dpkg-query -W -f='${Status}' "$PACKAGE_NAME" 2>/dev/null | grep -q "install ok installed"
IS_INSTALLED=$?

if [[ "$DESIRED_STATE" == "Installed" ]]; then
    if [[ $IS_INSTALLED -eq 0 ]]; then
        echo "true"
    else
        if apt-get install -y "$PACKAGE_NAME" &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
    fi
elif [[ "$DESIRED_STATE" == "Not Installed" ]]; then
    if [[ $IS_INSTALLED -ne 0 ]]; then
        echo "true"
    else
        if apt-get purge -y "$PACKAGE_NAME" &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
    fi
else
    echo "false"
fi