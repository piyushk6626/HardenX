#!/usr/bin/env bash

if [[ $EUID -ne 0 ]] || [[ $# -ne 1 ]] || ! [[ "$1" =~ ^-?[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if useradd -D -f "$1" &>/dev/null; then
    echo "true"
else
    echo "false"
fi