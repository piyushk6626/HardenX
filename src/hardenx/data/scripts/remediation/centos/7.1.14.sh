#!/bin/bash

if [ $# -ne 1 ]; then
    echo "false"
    exit 1
fi

USERNAME=$1

if passwd -l "$USERNAME" &> /dev/null; then
    echo "true"
else
    echo "false"
fi