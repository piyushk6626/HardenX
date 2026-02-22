#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

OWNER="$1"

if chown -R "$OWNER" /etc/audit/ &>/dev/null; then
    echo "true"
else
    echo "false"
fi