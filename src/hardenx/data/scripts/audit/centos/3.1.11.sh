#!/bin/bash

# Execute the command, redirecting stderr to stdout to capture all output
output=$(systemctl is-enabled cups 2>&1)
exit_code=$?

# If the exit code is 0, the command was successful and the output is the status.
if [ $exit_code -eq 0 ]; then
    echo "$output"
# If the output indicates the unit file doesn't exist, it's not installed.
elif [[ "$output" == *"No such file or directory"* ]]; then
    echo "not installed"
# Otherwise, the output is a valid status (like 'disabled' or 'masked'),
# even though the exit code was non-zero.
else
    echo "$output"
fi