#!/usr/bin/env bash

if modprobe --show-config | grep -qE '^\s*(install[[:space:]]+cramfs[[:space:]]+/bin/true|blacklist[[:space:]]+cramfs\b)'; then
    echo "disabled"
elif [ -d "/sys/module/cramfs" ]; then
    echo "loaded"
else
    echo "available"
fi