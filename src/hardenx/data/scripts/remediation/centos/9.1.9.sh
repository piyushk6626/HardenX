#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

permissions="$1"

if chmod "$permissions" /etc/shells &>/dev/null; then
    echo "true"
else
    echo "false"
fi