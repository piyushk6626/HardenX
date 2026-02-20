#!/usr/bin/env bash

if [[ "$1" == "disabled" ]]; then
    if systemctl disable --now named &> /dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi