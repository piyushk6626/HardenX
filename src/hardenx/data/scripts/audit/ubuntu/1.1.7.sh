#!/usr/bin/env bash

if modprobe -n -v squashfs 2>/dev/null | grep -q 'install /bin/true' && ! lsmod | grep -q "^squashfs\s"; then
    echo "Disabled"
else
    echo "Enabled"
fi