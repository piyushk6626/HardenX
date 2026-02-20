#!/usr/bin/env bash

if [[ "$1" == "Enabled" ]]; then
    if grub2-setpassword; then
        echo "true"
    else
        echo "false"
    fi
fi
