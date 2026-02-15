#!/usr/bin/env bash

if [[ "$1" != "empty" ]]; then
    echo "false"
    exit 0
fi

if gpasswd -M "" shadow &>/dev/null; then
    echo "true"
else
    echo "false"
fi