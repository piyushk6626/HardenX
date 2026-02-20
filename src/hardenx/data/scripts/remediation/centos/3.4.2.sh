#!/usr/bin/env bash

if [[ "$1" != "enabled_and_running" ]]; then
    echo "false"
    exit 1
fi

if systemctl enable --now systemd-timesyncd &>/dev/null; then
    echo "true"
else
    echo "false"
fi