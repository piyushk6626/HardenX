#!/usr/bin/env bash

output=$(systemctl is-enabled ufw 2>&1)
exit_code=$?

if [ $exit_code -ne 0 ]; then
    if [[ "$output" == *"No such file or directory"* || "$output" == *"Failed to get unit file state"* ]]; then
        echo "not found"
    else
        # This handles statuses like 'disabled', 'static', etc., which also have a non-zero exit code.
        echo "$output"
    fi
else
    # This handles the 'enabled' case, which has a zero exit code.
    echo "$output"
fi