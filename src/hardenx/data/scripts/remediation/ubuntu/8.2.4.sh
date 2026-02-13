#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Usage: $0 <numerical_value>" >&2
    false
fi

readonly VALUE="$1"
readonly RULES_FILE="/etc/audit/rules.d/audit.rules"
readonly SETTING="-b ${VALUE}"

# Ensure we are running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   false
fi

# Ensure the parent directory exists
if ! mkdir -p "$(dirname "$RULES_FILE")"; then
    echo "Error: Could not create directory for rules file." >&2
    false
fi

# Ensure the rules file itself exists
if ! touch "$RULES_FILE"; then
    echo "Error: Could not create rules file." >&2
    false
fi


if grep -qE '^-b\s' "$RULES_FILE"; then
    # The -b setting exists, so we replace it.
    if ! sed -i "s/^-b .*/${SETTING}/" "$RULES_FILE"; then
        echo "Error: Failed to update audit rule in ${RULES_FILE}" >&2
        false
    fi
else
    # The -b setting does not exist, so we append it.
    if ! echo "${SETTING}" >> "$RULES_FILE"; then
        echo "Error: Failed to add audit rule to ${RULES_FILE}" >&2
        false
    fi
fi

if ! augenrules --load; then
    echo "Error: Failed to reload audit rules with augenrules." >&2
    false
fi

true