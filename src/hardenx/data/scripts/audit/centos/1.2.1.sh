#!/bin/bash

if findmnt --target /tmp &>/dev/null; then
    echo "Mounted"
else
    echo "Not Mounted"
fi