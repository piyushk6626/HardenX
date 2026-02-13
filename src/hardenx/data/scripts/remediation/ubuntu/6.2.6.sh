#!/bin/bash

if [[ "$EUID" -ne 0 || $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

timeout_minutes=$1
if ! [[ "$timeout_minutes" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

config_file="/etc/sudoers.d/10-custom-timeout"
config_line="Defaults timestamp_timeout=${timeout_minutes}"
tmp_file=""

# Ensure temp file is cleaned up on exit
trap '[[ -n "$tmp_file" ]] && rm -f "$tmp_file"' EXIT

# Create a temporary file, write the configuration, and validate its syntax
tmp_file=$(mktemp)
if ! echo "$config_line" > "$tmp_file" || ! visudo -c -f "$tmp_file" &>/dev/null; then
    echo "false"
    exit 1
fi

# Move the validated file into place and set the correct permissions
if mv "$tmp_file" "$config_file" && chmod 0440 "$config_file"; then
    tmp_file="" # Prevent trap from trying to remove the moved file
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi