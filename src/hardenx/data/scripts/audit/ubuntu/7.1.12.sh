#!/bin/bash

BASHRC_FILE="/root/.bashrc"
PROFILE_FILE="/root/.profile"
umask_val=""

# Prioritize .bashrc
if [ -f "$BASHRC_FILE" ] && [ -r "$BASHRC_FILE" ]; then
    umask_val=$(grep -E '^\s*umask\s+[0-9]{3,4}' "$BASHRC_FILE" | tail -n 1 | awk '{print $2}')
fi

# If found in .bashrc, print and exit
if [ -n "$umask_val" ]; then
    printf "%s" "$umask_val"
    exit 0
fi

# Fallback to .profile
if [ -f "$PROFILE_FILE" ] && [ -r "$PROFILE_FILE" ]; then
    umask_val=$(grep -E '^\s*umask\s+[0-9]{3,4}' "$PROFILE_FILE" | tail -n 1 | awk '{print $2}')
fi

printf "%s" "$umask_val"