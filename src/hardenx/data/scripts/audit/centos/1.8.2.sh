#!/bin/bash

if findmnt -n --target /var/log/audit --output OPTIONS | grep -qw 'nodev'; then
    echo "Enabled"
else
    echo "Disabled"
fi