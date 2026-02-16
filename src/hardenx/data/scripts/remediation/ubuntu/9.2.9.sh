#!/usr/bin/env bash

if [[ "$#" -ne 1 || "$1" != "enforce" ]]; then
    echo "false"
    exit 1
fi

all_successful=true

# Use getent for portability (covers LDAP, etc.)
# Filter for UIDs >= 1000 and a shell that isn't nologin/false
getent passwd | awk -F: '$3 >= 1000 && $7 !~ /nologin|false$/ {print $1, $6}' | while IFS= read -r user home_dir; do
    # Check if the home directory field is set and if the directory does not exist
    if [[ -n "$home_dir" && ! -d "$home_dir" ]]; then
        if ! mkhomedir_helper "$user"; then
            all_successful=false
        fi
    fi
done

if [[ "$all_successful" == "true" ]]; then
    echo "true"
else
    echo "false"
fi