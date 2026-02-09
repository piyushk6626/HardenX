#!/usr/bin/env bash

mount_options=$(findmnt -n --target /var/log/audit --output OPTIONS 2>/dev/null)

if [ -z "$mount_options" ]; then
    echo "not_configured"
    exit 0
fi

if echo "$mount_options" | grep -q '\bnosuid\b'; then
    echo "enabled"
else
    echo "disabled"
fi