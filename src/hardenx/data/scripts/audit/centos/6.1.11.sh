#!/usr/bin/env bash

config_file="/etc/ssh/sshd_config"
default_value="yes"

# Search for the uncommented setting, case-insensitive.
# Take the last instance if multiple exist, which is sshd's behavior.
# Extract the second field (the value) and convert to lowercase.
value=$(grep -iE '^[[:space:]]*IgnoreRhosts[[:space:]]+(yes|no)' "$config_file" 2>/dev/null | tail -n 1 | awk '{print tolower($2)}')

if [[ -n "$value" ]]; then
    echo "$value"
else
    echo "$default_value"
fi