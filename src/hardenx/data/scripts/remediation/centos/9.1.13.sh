#!/bin/bash

if [ $# -ne 1 ] || [ ! -e "$1" ]; then
    echo "false"
    exit 1
fi

if chmod u-s,g-s "$1" &>/dev/null; then
    echo "true"
else
    echo "false"
fi