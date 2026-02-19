#!/bin/bash

if findmnt --noheadings --output OPTIONS /dev/shm | grep -q '\bnoexec\b'; then
    echo "Enabled"
else
    echo "Disabled"
fi