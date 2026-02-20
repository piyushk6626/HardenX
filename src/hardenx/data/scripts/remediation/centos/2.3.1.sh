#!/bin/bash

if [[ "$#" -ne 1 || "$EUID" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONTENT="$1"

# Use a subshell to group commands and easily check the final exit code.
# Redirect stdout and stderr of the commands to /dev/null to ensure only
# our "true" or "false" is printed.
(
    echo "$CONTENT" > /etc/issue && \
    chown root:root /etc/issue && \
    chmod 644 /etc/issue
) &> /dev/null

if [[ $? -eq 0 ]]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi