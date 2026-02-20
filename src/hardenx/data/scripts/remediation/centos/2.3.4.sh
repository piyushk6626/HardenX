#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

if chown root:root /etc/issue && chmod "$1" /etc/issue; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi