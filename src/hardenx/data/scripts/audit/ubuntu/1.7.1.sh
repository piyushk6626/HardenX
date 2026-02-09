#!/usr/bin/env bash

varlog_source=$(findmnt --noheadings --output=SOURCE /var/log)
root_source=$(findmnt --noheadings --output=SOURCE /)

if [ -z "$varlog_source" ]; then
    echo "Not Mounted"
    exit 0
fi

if [ "$varlog_source" != "$root_source" ]; then
    echo "Mounted"
else
    echo "Not Mounted"
fi