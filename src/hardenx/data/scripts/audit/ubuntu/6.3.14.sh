#!/usr/bin/env bash

CONF_FILE="/etc/security/pwquality.conf"
SETTING="maxsequence"
DEFAULT_VALUE="0"

if [[ -f "$CONF_FILE" && -r "$CONF_FILE" ]]; then
    # Search for the setting, ignoring commented out lines.
    # The grep regex looks for a line starting with optional whitespace,
    # the setting name, an equals sign, and then captures the value.
    value=$(grep -E "^\s*${SETTING}\s*=" "$CONF_FILE" | tail -n 1 | cut -d '=' -f 2 | xargs)
fi

# Use shell parameter expansion: if 'value' is unset or null, use DEFAULT_VALUE.
echo "${value:-$DEFAULT_VALUE}"