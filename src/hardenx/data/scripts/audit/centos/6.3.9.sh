#!/usr/bin/env bash

CONF_FILE="/etc/security/faillock.conf"
DEFAULT_VALUE="900"

if [[ -r "$CONF_FILE" ]]; then
    # Search for the unlock_time setting, ignore comments and whitespace.
    # awk action: find the line, strip whitespace and trailing comments from the value, print it, and exit.
    value=$(awk -F= '/^\s*unlock_time\s*=/ {gsub(/[[:space:]]|#.*/, "", $2); print $2; exit}' "$CONF_FILE")
fi

# If 'value' is empty (file not found, setting not in file), use the default.
echo "${value:-$DEFAULT_VALUE}"