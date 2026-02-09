#!/usr/bin/env bash

if findmnt -n -o OPTIONS /tmp | grep -wq 'nosuid'; then
    echo 'true'
else
    echo 'false'
fi