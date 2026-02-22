#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

PERMISSIONS="$1"

# Basic validation for an octal-like string
if ! [[ "$PERMISSIONS" =~ ^[0-7]{3,4}$ ]]; then
    echo "false"
    exit 1
fi

if chmod "$PERMISSIONS" /etc/group &>/dev/null; then
    echo "true"
else
    echo "false"
fi