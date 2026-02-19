#!/usr/bin/env bash

if ! command -v ufw &> /dev/null; then
    echo "Not Installed"
    exit 0
fi

if systemctl is-active --quiet ufw || systemctl is-enabled --quiet ufw; then
    echo "Enabled"
else
    echo "Disabled"
fi