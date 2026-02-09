#!/bin/bash

if mountpoint -q /home; then
    echo "Mounted"
else
    echo "Not Mounted"
fi