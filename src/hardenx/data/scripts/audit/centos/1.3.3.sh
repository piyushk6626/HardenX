#!/bin/bash

if findmnt -n -o OPTIONS /dev/shm | grep -q 'nosuid'; then
    echo "true"
else
    echo "false"
fi