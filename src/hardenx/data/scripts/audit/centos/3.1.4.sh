#!/usr/bin/env bash

if ! command -v named &>/dev/null; then
    echo "Not Installed"
    exit 0
fi

status=$(systemctl is-enabled named 2>/dev/null)

if [[ -n "$status" ]]; then
    echo "$status"
else
    # Default to disabled if the service file isn't found or systemctl fails
    echo "disabled"
fi