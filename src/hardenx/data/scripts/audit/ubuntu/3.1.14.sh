#!/usr/bin/env bash

if ! command -v smbd &> /dev/null; then
    echo "Not Installed"
    exit 0
fi

if systemctl is-active --quiet smbd && systemctl is-enabled --quiet smbd; then
    echo "Enabled"
else
    echo "Disabled"
fi