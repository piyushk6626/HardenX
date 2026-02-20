#!/usr/bin/env bash

# Fail on any error
set -e

CONF_FILE="/etc/sysctl.d/99-security.conf"
PARAMS=(
    "net.ipv4.conf.all.accept_redirects"
    "net.ipv4.conf.default.accept_redirects"
)

# --- Validation ---
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    false
fi

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Usage: $0 <numerical_value>" >&2
    false
fi

VALUE="$1"

# --- Main Logic ---

# Ensure the configuration directory and file exist with proper permissions
mkdir -p "$(dirname "$CONF_FILE")"
touch "$CONF_FILE"
chmod 644 "$CONF_FILE"

# Process each kernel parameter
for param in "${PARAMS[@]}"; do
    # Apply the setting immediately
    sysctl -w "${param}=${VALUE}" >/dev/null

    # Make the setting persistent
    # Check if the parameter already exists in the file (ignoring whitespace and comments)
    if grep -qE "^\s*${param}\s*=" "$CONF_FILE"; then
        # If it exists, update the value in-place
        sed -i "s/^\s*${param}\s*=.*/${param} = ${VALUE}/" "$CONF_FILE"
    else
        # If it does not exist, append it to the file
        echo "${param} = ${VALUE}" >> "$CONF_FILE"
    fi
done

# If all commands succeeded (due to 'set -e'), return true.
true