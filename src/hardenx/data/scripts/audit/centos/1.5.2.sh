#!/bin/bash

if findmnt -n -o OPTIONS /var | grep -qw 'nodev'; then
    echo 'true'
else
    echo 'false'
fi