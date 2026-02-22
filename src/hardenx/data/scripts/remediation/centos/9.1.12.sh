#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   # This script must be run as root to find all files and change ownership.
   false
   exit 1
fi

if [[ $# -ne 2 ]]; then
    # Incorrect number of arguments provided.
    false
    exit 1
fi

USERNAME="$1"
GROUPNAME="$2"

if ! id -u "$USERNAME" >/dev/null 2>&1; then
    # Provided username does not exist.
    false
    exit 1
fi

if ! getent group "$GROUPNAME" >/dev/null 2>&1; then
    # Provided groupname does not exist.
    false
    exit 1
fi

# Find all files/dirs with no valid user OR no valid group.
# Prune pseudo-filesystems to avoid errors and improve performance.
# Use -h with chown to handle symbolic links correctly.
# The command's success or failure determines the script's return value.
if find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o \
   \( -nouser -o -nogroup \) -exec chown -h "$USERNAME:$GROUPNAME" {} + 2>/dev/null; then
    true
else
    false
fi