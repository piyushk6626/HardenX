#!/bin/bash

CONF_FILE="/etc/security/pwquality.conf"
DEFAULT_MINLEN=9

minlen_value=$(awk -F= '/^\s*minlen/ {gsub(/[[:space:]]/, "", $2); print $2; exit}' "$CONF_FILE" 2>/dev/null)

if [[ -n "$minlen_value" && "$minlen_value" =~ ^-?[0-9]+$ ]]; then
    echo "$minlen_value"
else
    echo "$DEFAULT_MINLEN"
fi