#!/usr/bin/env bash

if [[ $EUID -ne 0 ]] || [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-7]{3}$ ]]; then
    echo "false"
    exit 1
fi

NEW_UMASK="$1"
LOGIN_DEFS_FILE="/etc/login.defs"

if [[ ! -f "$LOGIN_DEFS_FILE" ]] || [[ ! -w "$LOGIN_DEFS_FILE" ]]; then
    echo "false"
    exit 1
fi

# Case 1: Active UMASK line exists. Modify it.
if grep -qE '^\s*UMASK\s+[0-7]{3}' "$LOGIN_DEFS_FILE"; then
    sed -i -r "s/^(UMASK\s+)[0-7]{3}.*$/\1${NEW_UMASK}/" "$LOGIN_DEFS_FILE"

# Case 2: Commented UMASK line exists. Uncomment and modify it.
elif grep -qE '^\s*#\s*UMASK\s+[0-7]{3}' "$LOGIN_DEFS_FILE"; then
    # This sed command finds the first occurrence of a commented UMASK line
    # and replaces it with the new, active setting.
    sed -i -r "0,/^\s*#\s*UMASK\s+[0-7]{3}.*$/s//UMASK           ${NEW_UMASK}/" "$LOGIN_DEFS_FILE"

# Case 3: No UMASK line exists. Add it.
else
    # Add a newline before appending to avoid adding to the last line.
    echo "" >> "$LOGIN_DEFS_FILE"
    echo "UMASK           ${NEW_UMASK}" >> "$LOGIN_DEFS_FILE"
fi

# Verify the change was successful
if grep -qE "^\s*UMASK\s+${NEW_UMASK}\s*(\#.*)?$" "$LOGIN_DEFS_FILE"; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi