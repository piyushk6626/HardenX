#!/bin/bash

CONF_FILE="/etc/security/faillock.conf"
DEFAULT_VALUE="600"

if [[ ! -f "$CONF_FILE" ]]; then
    echo "$DEFAULT_VALUE"
    exit 0
fi

value=$(grep -E '^\s*unlock_time\s*=' "$CONF_FILE" | awk -F'=' '{print $2}' | tr -d '[:space:]')

if [[ -n "$value" ]]; then
    echo "$value"
else
    echo "$DEFAULT_VALUE"
fi