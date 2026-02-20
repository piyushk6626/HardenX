#!/bin/bash

if [ "$#" -eq 1 ] && [ "$1" == "enabled" ]; then
    if systemctl enable --now ufw &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi