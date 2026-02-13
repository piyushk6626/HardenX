#!/bin/bash

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "false"
    exit 1
fi

USERNAME="$1"

if usermod --shell /usr/sbin/nologin "$USERNAME" &> /dev/null; then
    echo "true"
else
    echo "false"
fi