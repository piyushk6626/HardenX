#!/bin/bash

FILE_PATH="/boot/grub/grub.cfg"

if [ -f "$FILE_PATH" ]; then
    stat -c '%U:%G %a' "$FILE_PATH"
else
    exit 1
fi