#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 0
fi

if [ -f "/etc/gshadow-" ] && chmod "$1" "/etc/gshadow-" &>/dev/null; then
    echo "true"
else
    echo "false"
fi