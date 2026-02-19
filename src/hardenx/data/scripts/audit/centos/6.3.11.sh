#!/usr/bin/env bash

CONF_FILE="/etc/security/pwquality.conf"
DEFAULT_DIFOK=5

if [[ ! -r "$CONF_FILE" ]]; then
    echo "$DEFAULT_DIFOK"
    exit 0
fi

# Use grep to find the line that starts with 'difok' (ignoring leading whitespace)
# and is not commented out. Then use sed to extract just the numerical value.
VALUE=$(grep -E '^\s*difok\s*=' "$CONF_FILE" | sed -e 's/.*=//' -e 's/[^0-9]*//g')

if [[ "$VALUE" =~ ^[0-9]+$ ]]; then
    echo "$VALUE"
else
    echo "$DEFAULT_DIFOK"
fi