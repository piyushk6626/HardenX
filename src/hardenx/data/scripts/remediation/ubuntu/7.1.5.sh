#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

input="$1"

if ! [[ "$input" =~ ^[1-9][0-9]*$ ]]; then
    echo "false"
    exit 1
fi

if useradd -D -f "$input" &>/dev/null; then
    echo "true"
else
    echo "false"
fi