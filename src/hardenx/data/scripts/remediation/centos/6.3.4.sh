#!/bin/bash

if [[ $# -ne 1 ]] || [[ "$1" != "Enabled" ]]; then
    echo "false"
    exit 1
fi

# Modern systems (RHEL/CentOS 8+, Fedora)
if command -v authselect &>/dev/null; then
    if authselect select minimal --force &>/dev/null; then
        echo "true"
        exit 0
    else
        echo "false"
        exit 1
    fi
# Older systems (RHEL/CentOS 6/7)
elif command -v authconfig &>/dev/null; then
    if authconfig --enableunix --update &>/dev/null; then
        echo "true"
        exit 0
    else
        echo "false"
        exit 1
    fi
else
    # If neither tool is found, we cannot perform the action.
    echo "false"
    exit 1
fi