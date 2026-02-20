#!/bin/bash

if [ $# -ne 1 ]; then
    echo "false"
    exit 1
fi

PERMISSIONS="$1"

# Suppress all command output, rely only on exit codes
if chown root:root /etc/crontab &>/dev/null && chmod "${PERMISSIONS}" /etc/crontab &>/dev/null; then
    echo "true"
else
    echo "false"
fi