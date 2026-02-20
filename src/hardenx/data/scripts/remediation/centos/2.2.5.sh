#!/usr/bin/env bash

if [[ "$1" != "disabled" ]]; then
    echo "false"
    exit 0
fi

if systemctl stop abrtd &>/dev/null && systemctl disable abrtd &>/dev/null; then
    echo "true"
else
    echo "false"
fi