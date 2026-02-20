#!/usr/bin/env bash

if [[ "$1" == "enabled" ]]; then
    if systemctl enable --now systemd-journald &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
elif [[ "$1" == "disabled" ]]; then
    if systemctl disable --now systemd-journald &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi