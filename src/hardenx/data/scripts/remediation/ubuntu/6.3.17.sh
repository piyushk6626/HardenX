#!/bin/bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

MODE="$1"
if [[ "$MODE" != "enforced" && "$MODE" != "not enforced" ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/pam.d/common-password"
PATTERN_TEXT="password requisite pam_pwquality.so retry=3"
PATTERN_REGEX="^[[:space:]]*password[[:space:]]+requisite[[:space:]]+pam_pwquality\.so[[:space:]]+retry=3"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

if [[ "$MODE" == "enforced" ]]; then
    if grep -qE "$PATTERN_REGEX" "$CONFIG_FILE"; then
        # Already exists and is uncommented. Success.
        :
    elif grep -qE "^\s*#\s*${PATTERN_TEXT}" "$CONFIG_FILE"; then
        # Exists but is commented. Uncomment it.
        sed -i.bak "s|^\s*#\s*\(${PATTERN_TEXT}\)|\1|" "$CONFIG_FILE"
    else
        # Does not exist. Add it.
        echo "$PATTERN_TEXT" >> "$CONFIG_FILE"
    fi
elif [[ "$MODE" == "not enforced" ]]; then
    # Comment out the line if it exists and is not already commented.
    sed -i.bak -E "s|(${PATTERN_REGEX})|#\1|" "$CONFIG_FILE"
fi

if [[ $? -eq 0 ]]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi