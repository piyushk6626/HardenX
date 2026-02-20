#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ -z "$1" ]]; then
    false
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    false
    exit 1
fi

CIPHERS_LIST="$1"
CONFIG_FILE="/etc/ssh/sshd_config"
TMP_FILE=$(mktemp)

# Ensure temp file is cleaned up on script exit
trap 'rm -f "$TMP_FILE"' EXIT

if ! [[ -f "$CONFIG_FILE" ]] || ! [[ -w "$CONFIG_FILE" ]]; then
    false
    exit 1
fi

# Use awk to find and replace the Ciphers line, or append it if not found.
# This is safer and more atomic than multiple grep/sed/echo commands.
awk -v ciphers="$CIPHERS_LIST" '
    # Match existing Ciphers line, commented or not, and replace it.
    /^#?[[:space:]]*Ciphers[[:space:]]/ {
        print "Ciphers " ciphers
        matched=1
        next
    }
    # Print all other lines verbatim.
    { print }
    # After processing the whole file, if no match was found, append the new line.
    END {
        if (matched != 1) {
            print "Ciphers " ciphers
        }
    }
' "$CONFIG_FILE" > "$TMP_FILE"

# Check that awk succeeded and the temp file is not empty.
if [[ $? -ne 0 ]] || ! [[ -s "$TMP_FILE" ]]; then
    false
    exit 1
fi

# Atomically replace the original config file with the temp file.
# Using 'cat' and redirection preserves file permissions and ownership.
if cat "$TMP_FILE" > "$CONFIG_FILE"; then
    true
else
    false
fi