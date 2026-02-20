#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <policy>" >&2
    exit 1
fi

if ufw default "$1"; then
    true
else
    false
fi