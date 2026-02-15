#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

if chmod "$1" /etc/shells &>/dev/null; then
    echo "true"
else
    echo "false"
fi