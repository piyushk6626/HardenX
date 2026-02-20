#!/bin/bash

if [[ "$1" != "Enabled and Active" ]]; then
    echo "false"
    exit 1
fi

if systemctl enable --now chronyd &>/dev/null; then
    if systemctl is-active --quiet chronyd && systemctl is-enabled --quiet chronyd; then
        echo "true"
        exit 0
    else
        echo "false"
        exit 1
    fi
else
    echo "false"
    exit 1
fi