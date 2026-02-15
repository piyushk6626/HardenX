#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

TARGET_USER="$1"

if chown -R "${TARGET_USER}:${TARGET_USER}" /etc/audit/ &> /dev/null; then
    echo "true"
else
    echo "false"
fi