#!/bin/bash

CONFIG_FILE="/etc/default/apport"

if [ -f "$CONFIG_FILE" ]; then
    awk -F'=' '/^enabled=/ {print $2; exit}' "$CONFIG_FILE"
else
    echo "Not Installed"
fi