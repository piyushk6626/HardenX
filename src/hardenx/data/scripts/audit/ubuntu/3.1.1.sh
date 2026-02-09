#!/usr/bin/env bash

if ! systemctl cat autofs.service &> /dev/null; then
    echo "Not Installed"
    exit 0
fi

if systemctl is-enabled autofs &> /dev/null; then
    echo "Enabled"
else
    echo "Disabled"
fi