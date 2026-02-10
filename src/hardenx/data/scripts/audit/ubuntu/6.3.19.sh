#!/usr/bin/env bash

# Find the line containing pam_pwhistory.so, suppress errors if file doesn't exist
line=$(grep 'pam_pwhistory.so' /etc/pam.d/common-password 2>/dev/null)

# If the line was found, try to extract the remember value
if [ -n "$line" ]; then
    # Use regex to find remember= and capture the digits that follow
    if [[ $line =~ remember=([0-9]+) ]]; then
        # The captured number is in the BASH_REMATCH array at index 1
        echo "${BASH_REMATCH[1]}"
    else
        # The line was found but the remember parameter was not
        echo "0"
    fi
else
    # The line was not found (or the file doesn't exist)
    echo "0"
fi