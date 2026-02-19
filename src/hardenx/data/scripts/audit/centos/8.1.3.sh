#!/usr/bin/env bash

value=$(grep -E '^[[:space:]]*SystemMaxUse=' /etc/systemd/journald.conf 2>/dev/null | cut -d'=' -f2)

if [[ -n "$value" ]]; then
    echo "$value"
else
    echo "default"
fi