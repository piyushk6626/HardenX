#!/usr/bin/env bash

CONF_FILE="/etc/security/pwquality.conf"
RESULT=0

if [[ -r "$CONF_FILE" ]]; then
    setting_line=$(grep -E '^[[:space:]]*dictcheck[[:space:]]*=' "$CONF_FILE")

    if [[ -n "$setting_line" ]]; then
        value=$(echo "$setting_line" | sed -e 's/.*=[[:space:]]*//' -e 's/[[:space:]]*#.*//' | tr -d '[:space:]')
        
        if [[ "$value" -eq 1 ]]; then
            RESULT=1
        fi
    fi
fi

echo "$RESULT"