#!/bin/bash

if [ -z "$1" ]; then
    echo "false"
    exit 1
fi

if chmod "$1" /etc/cron.d &>/dev/null; then
    echo "true"
else
    echo "false"
fi