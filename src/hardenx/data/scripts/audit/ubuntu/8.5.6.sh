#!/usr/bin/env bash

# Find the first file in /etc/audit/ and its subdirectories not owned by root.
# The -printf '%u\n' action prints the username of the file's owner.
# grep -v filters out lines that exactly match 'root'.
# head -n 1 takes only the first result.
# 2>/dev/null suppresses any permission errors from find.
NON_ROOT_OWNER=$(find /etc/audit/ -type f -printf '%u\n' 2>/dev/null | grep -v '^root$' | head -n 1)

# Check if the variable is empty.
# If it is empty, all files were owned by root.
if [[ -z "$NON_ROOT_OWNER" ]]; then
    echo "root"
else
    # If it's not empty, it contains the first non-root owner.
    echo "$NON_ROOT_OWNER"
fi