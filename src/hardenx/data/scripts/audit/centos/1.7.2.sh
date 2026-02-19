#!/bin/bash

if findmnt -n --target /var/log --output OPTIONS 2>/dev/null | grep -q '\bnodev\b'; then
    echo "true"
else
    echo "false"
fi