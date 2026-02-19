#!/bin/bash

options=$(findmnt -n -o OPTIONS /var/log 2>/dev/null)

if [[ -n "$options" && "$options" == *nosuid* ]]; then
    echo "nosuid"
else
    echo "missing"
fi