#!/bin/bash

if findmnt -n -o OPTIONS --target /var | grep -qw 'nodev'; then
    echo "Enabled"
else
    echo "Disabled"
fi