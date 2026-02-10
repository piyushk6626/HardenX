#!/usr/bin/env bash

# Concatenate the main sudoers file and all files in the sudoers.d directory.
# Filter for lines that define a Defaults entry containing timestamp_timeout.
# Use sed to extract only the numeric value of the timeout.
# Since later entries override earlier ones, take the very last value found.
# The '2>/dev/null' suppresses errors if /etc/sudoers.d doesn't exist or is empty.

timeout_value=$(cat /etc/sudoers /etc/sudoers.d/* 2>/dev/null | \
                sed -n 's/^\s*Defaults.*timestamp_timeout=\([0-9-]\+\).*/\1/p' | \
                tail -n 1)

# If a value was found and assigned to the variable, print it.
# Otherwise, print the default value of 15.
if [ -n "$timeout_value" ]; then
    echo "$timeout_value"
else
    echo "15"
fi