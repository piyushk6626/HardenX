#!/usr/bin/env bash

CONF_FILE="/etc/security/pwquality.conf"
DEFAULT_VALUE="0"

# Attempt to find the setting, ignoring commented lines and surrounding whitespace.
# awk is used to find the line, extract the value after '=', and clean it.
VALUE=$(awk -F= '/^\s*maxrepeat\s*=/ {
                val=$2
                sub(/#.*/, "", val)
                gsub(/^[ \t]+|[ \t]+$/, "", val)
                print val
                exit
            }' "$CONF_FILE" 2>/dev/null)

if [[ -n "$VALUE" ]]; then
    echo "$VALUE"
else
    echo "$DEFAULT_VALUE"
fi