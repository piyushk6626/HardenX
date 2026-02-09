#!/bin/bash

mount_options=$(findmnt -n -o OPTIONS --target /home)

if [ -z "$mount_options" ]; then
    echo "Not Applicable"
    exit 0
fi

if echo "$mount_options" | grep -qw 'nodev'; then
    echo "Enabled"
else
    echo "Disabled"
fi