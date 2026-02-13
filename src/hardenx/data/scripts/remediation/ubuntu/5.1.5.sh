#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

policy="$1"

if [[ "$policy" != "allow" && "$policy" != "deny" ]]; then
    echo "false"
    exit 1
fi

if sudo ufw default "$policy" outgoing &>/dev/null; then
    echo "true"
else
    echo "false"
fi