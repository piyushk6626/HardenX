#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
    echo "false"
    exit 1
fi

if ufw default "$1" incoming &>/dev/null && ufw default "$2" outgoing &>/dev/null; then
    echo "true"
else
    echo "false"
fi