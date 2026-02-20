#!/bin/bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

WARN_DAYS="$1"
CONFIG_FILE="/etc/login.defs"
PARAM="PASS_WARN_AGE"

if ! [[ -f "$CONFIG_FILE" && -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# Check if the parameter already exists (and is not commented out)
if grep -qE "^\s*${PARAM}\s+" "$CONFIG_FILE"; then
    # Parameter exists, so replace its value
    sed -i "s/^\s*${PARAM}\s+.*/${PARAM}\t${WARN_DAYS}/" "$CONFIG_FILE"
else
    # Parameter does not exist, so append it
    echo -e "${PARAM}\t${WARN_DAYS}" >> "$CONFIG_FILE"
fi

if [[ $? -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi