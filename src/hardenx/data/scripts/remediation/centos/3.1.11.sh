#!/bin/bash

if [ "$#" -ne 1 ] || [ "$1" != "disabled" ]; then
    echo "false"
    exit 0
fi

if systemctl disable --now cups &>/dev/null; then
    echo "true"
else
    echo "false"
fi