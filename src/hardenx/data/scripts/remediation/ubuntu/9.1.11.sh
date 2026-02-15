#!/usr/bin/env bash

if [[ $# -eq 1 && "$1" == "enforce" ]]; then
    if find / -xdev -perm -o=w -exec chmod o-w {} +; then
        echo "true"
    else
        echo "false"
    fi
fi