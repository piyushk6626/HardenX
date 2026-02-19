#!/usr/bin/env bash

log_source=$(findmnt -n -o SOURCE --target /var/log)
root_source=$(findmnt -n -o SOURCE --target /)

if [ "$log_source" == "$root_source" ]; then
    echo 'Not a separate partition'
    exit 0
fi

if findmnt -n -o OPTIONS --target /var/log | grep -q '\bnoexec\b'; then
    echo 'enabled'
else
    echo 'disabled'
fi