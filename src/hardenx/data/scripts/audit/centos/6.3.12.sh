#!/usr/bin/env bash

DEFAULT_MINLEN=9
CONF_FILE="/etc/security/pwquality.conf"

# Awk finds lines starting with 'minlen' (ignoring leading whitespace),
# splits by '=', takes the second part, removes all whitespace, and prints it.
# If the file doesn't exist or the setting isn't present, awk produces no output.
minlen_setting=$(awk -F= '/^[[:space:]]*minlen/ {gsub(/[[:space:]]/, "", $2); print $2}' "$CONF_FILE" 2>/dev/null)

echo "${minlen_setting:-$DEFAULT_MINLEN}"