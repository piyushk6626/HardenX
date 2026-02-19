#!/bin/bash

if findmnt --target /dev/shm &>/dev/null; then
    echo "mounted"
else
    echo "not mounted"
fi