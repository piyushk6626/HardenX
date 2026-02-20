#!/bin/bash

if [[ "$#" -ne 1 || "$1" != "disabled" ]]; then
    echo "false"
    exit 1
fi

if nmcli radio wifi off &>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi