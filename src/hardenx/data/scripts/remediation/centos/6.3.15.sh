#!/usr/bin/env bash

set -e
set -o pipefail

CONF_FILE="/etc/security/pwquality.conf"
KEY="dictcheck"

# --- Argument and Permission Validation ---
if [[ "$#" -ne 1 ]]; then
    echo "Error: A single argument (0 or 1) is required." >&2
    false
    exit $?
fi

VALUE="$1"
if [[ "$VALUE" != "0" && "$VALUE" != "1" ]]; then
    echo "Error: Argument must be 0 or 1." >&2
    false
    exit $?
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2
    false
    exit $?
fi

if [[ ! -w "$CONF_FILE" ]]; then
    # Handle case where file exists but isn't writable
    if [[ -e "$CONF_FILE" ]]; then
        echo "Error: Configuration file ${CONF_FILE} is not writable." >&2
        false
        exit $?
    fi
    # Handle case where file doesn't exist but directory isn't writable
    if ! touch "$CONF_FILE" 2>/dev/null; then
        echo "Error: Cannot create or write to ${CONF_FILE}." >&2
        false
        exit $?
    fi
fi

# --- Main Logic ---
SETTING="${KEY} = ${VALUE}"

# Check if an uncommented entry already exists.
# The regex accounts for various whitespace arrangements.
if grep -qE "^[[:space:]]*${KEY}[[:space:]]*=" "${CONF_FILE}"; then
    # Update the existing line
    sed -i "s/^[[:space:]]*${KEY}[[:space:]]*=.*/${SETTING}/" "${CONF_FILE}"
else
    # Add the new setting to the end of the file
    echo "${SETTING}" >> "${CONF_FILE}"
fi

# If we reached here, 'set -e' ensures all commands succeeded.
true