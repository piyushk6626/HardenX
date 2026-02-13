#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

STATE="$1"

if [[ "$STATE" != "disable" && "$STATE" != "mask" ]]; then
    echo "false"
    exit 1
fi

if systemctl stop bluetooth &>/dev/null && systemctl "$STATE" bluetooth &>/dev/null; then
    echo "true"
else
    echo "false"
fi