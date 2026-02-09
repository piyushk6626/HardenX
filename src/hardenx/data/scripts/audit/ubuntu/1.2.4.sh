#!/bin/bash

if findmnt -n -o OPTIONS /tmp | grep -qw 'noexec'; then
    echo "Present"
else
    echo "Not Present"
fi