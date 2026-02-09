#!/bin/bash

if findmnt --mountpoint /tmp &> /dev/null; then
    echo "mounted"
else
    echo "not mounted"
fi