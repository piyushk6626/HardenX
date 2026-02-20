#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if ufw default "$1" outgoing &>/dev/null; then
    echo "true"
else
    echo "false"
fi