#!/bin/bash

if findmnt -n -o OPTIONS /dev/shm | grep -q '\bnodev\b'; then
    echo 'present'
else
    echo 'absent'
fi