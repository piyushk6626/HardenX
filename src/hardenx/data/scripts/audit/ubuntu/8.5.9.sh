#!/bin/bash

# Define the list of audit tool binaries
files=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
)

# Find the unique owners of the specified files that exist
# The -maxdepth 0 prevents find from descending into directories
# 2>/dev/null suppresses errors for files that do not exist
mapfile -t owners < <(find "${files[@]}" -maxdepth 0 -printf '%U\n' 2>/dev/null | sort -u)

# Check the number of unique owners found
if [[ ${#owners[@]} -eq 1 ]]; then
    # If there is exactly one unique owner, print it
    echo "${owners[0]}"
else
    # If there are zero or more than one unique owners, the state is inconsistent
    echo "Mixed"
fi