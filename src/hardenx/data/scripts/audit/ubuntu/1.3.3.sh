#!/bin/bash

if findmnt -n -o OPTIONS /dev/shm 2>/dev/null | grep -q '\bnosuid\b'; then
    echo "nosuid"
else
    echo "missing"
fi