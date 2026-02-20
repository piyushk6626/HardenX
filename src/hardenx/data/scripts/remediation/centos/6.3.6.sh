#!/bin/bash

if [[ "$1" != "enabled" ]]; then
    echo "false"
    exit 1
fi

if authconfig --enablepwquality --updateall &>/dev/null; then
    echo "true"
else
    echo "false"
fi