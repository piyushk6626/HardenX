#!/bin/bash

if findmnt -n -o OPTIONS /dev/shm | grep -q '\bnodev\b'; then
    echo "true"
else
    echo "false"
fi