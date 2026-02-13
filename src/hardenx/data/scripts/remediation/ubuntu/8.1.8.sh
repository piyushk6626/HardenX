#!/usr/bin/env bash

set -uo pipefail

# This script must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

new_mode="$1"

# Validate the mode is a 4-digit octal number like 0640
if ! [[ "$new_mode" =~ ^0[0-7]{3}$ ]]; then
    echo "false"
    exit 1
fi

# Configuration files to check, handle non-matching glob
shopt -s nullglob
config_files=("/etc/rsyslog.conf" /etc/rsyslog.d/*.conf)
shopt -u nullglob

directive="\$FileCreateMode"
found_and_updated=false

# Iterate through existing config files to find and update the directive
for file in "${config_files[@]}"; do
    if [[ -f "$file" ]] && grep -qE "^\s*${directive}" "$file"; then
        # Use a temporary file and atomic move for safer in-place editing
        tmp_file=$(mktemp)
        if ! sed "s|^\s*${directive}.*|${directive} ${new_mode}|" "$file" > "$tmp_file" || \
           ! mv "$tmp_file" "$file"; then
            rm -f "$tmp_file"
            echo "false"
            exit 1
        fi
        found_and_updated=true
        # We update all occurrences, so we don't break here.
    fi
done

# If the directive was not found in any existing file, add it to a new file
if ! $found_and_updated; then
    new_config_file="/etc/rsyslog.d/99-filecreatemode-override.conf"
    if ! echo "${directive} ${new_mode}" > "$new_config_file"; then
        echo "false"
        exit 1
    fi
fi

# Restart the rsyslog service to apply changes
if ! systemctl restart rsyslog; then
    echo "false"
    exit 1
fi

echo "true"
exit 0