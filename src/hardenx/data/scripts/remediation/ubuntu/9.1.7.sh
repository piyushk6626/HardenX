#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

PERM_MODE="$1"

if ! [[ "$PERM_MODE" =~ ^[0-7]{4}$ ]]; then
    echo "false"
    exit 1
fi

if chown root:shadow /etc/gshadow &>/dev/null && chmod "$PERM_MODE" /etc/gshadow &>/dev/null; then
    echo "true"
else
    echo "false"
fi