#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    exit 1
fi

if chmod "$1" /etc/gshadow &> /dev/null; then
    true
else
    false
fi