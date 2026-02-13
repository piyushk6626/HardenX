#!/bin/bash

if [[ "$1" == "enabled" ]]; then
    if pam-auth-update --enable unix --force &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
elif [[ "$1" == "disabled" ]]; then
    if pam-auth-update --disable unix --force &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
    exit 1
fi