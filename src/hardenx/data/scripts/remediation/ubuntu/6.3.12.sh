#!/usr/bin/env bash

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]] || [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

readonly minlen_value="$1"
readonly conf_file="/etc/security/pwquality.conf"

if [[ ! -f "$conf_file" ]] || [[ ! -w "$conf_file" ]]; then
    echo "false"
    exit 1
fi

# Check if the minlen parameter already exists (commented or uncommented)
if grep -q -E '^[[:space:]]*#?[[:space:]]*minlen[[:space:]]*=' "$conf_file"; then
    # If it exists, replace the line in-place
    sed -i -E "s/^[[:space:]]*#?[[:space:]]*minlen[[:space:]]*=.*/minlen = $minlen_value/" "$conf_file"
    rc=$?
else
    # If it does not exist, append it to the file
    echo "minlen = $minlen_value" >> "$conf_file"
    rc=$?
fi

if [[ $rc -eq 0 ]]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi