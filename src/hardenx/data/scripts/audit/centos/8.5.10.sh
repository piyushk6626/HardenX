#!/usr/bin/env bash

# Define the list of executables to check
AUDIT_TOOLS=("/sbin/auditctl" "/sbin/aureport" "/sbin/ausearch")

# Variable to store the reference group name. Initialize to empty.
reference_group=""

# Loop through each tool
for tool in "${AUDIT_TOOLS[@]}"; do
    # Check if the file exists and is executable. If not, exit silently.
    if [[ ! -x "$tool" ]]; then
        exit 1
    fi

    # Get the group name of the current tool
    current_group=$(stat -c %G "$tool")

    # If this is the first tool, set its group as the reference
    if [[ -z "$reference_group" ]]; then
        reference_group="$current_group"
    # Otherwise, compare the current tool's group with the reference group
    elif [[ "$current_group" != "$reference_group" ]]; then
        # Mismatch found. Exit silently with an error code.
        exit 1
    fi
done

# If the loop finished and we have a reference group, all groups matched.
if [[ -n "$reference_group" ]]; then
    echo "$reference_group"
else
    # This case occurs if the AUDIT_TOOLS array is empty. Exit silently.
    exit 1
fi