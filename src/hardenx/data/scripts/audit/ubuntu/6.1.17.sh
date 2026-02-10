#!/usr/bin/env bash

CONFIG_FILE="/etc/ssh/sshd_config"
DEFAULT_VALUE="10"

if [[ ! -r "$CONFIG_FILE" ]]; then
    echo "$DEFAULT_VALUE"
    exit 0
fi

VALUE=$(grep -E '^\s*MaxSessions\s+' "$CONFIG_FILE" | awk '{print $2}')

if [[ -n "$VALUE" ]]; then
    echo "$VALUE"
else
    echo "$DEFAULT_VALUE"
fi