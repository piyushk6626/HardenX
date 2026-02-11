#!/usr/bin/env bash

CONF_FILE="/etc/systemd/journald.conf"
DEFAULT_VALUE="yes"

effective_value=$(grep -E '^[[:space:]]*ForwardToSyslog=' "$CONF_FILE" 2>/dev/null | cut -d'=' -f2 | xargs)

if [ -z "$effective_value" ]; then
    echo "$DEFAULT_VALUE"
else
    echo "$effective_value"
fi