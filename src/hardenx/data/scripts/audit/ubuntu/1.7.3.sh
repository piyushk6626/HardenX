#!/usr/bin/env bash

if findmnt -n -o OPTIONS /var/log | grep -qw 'nosuid'; then
    echo "present"
else
    echo "absent"
fi