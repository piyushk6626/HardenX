#!/usr/bin/env bash

if modprobe -n -v jffs2 2>/dev/null | grep -q 'install /bin/true' && ! lsmod | grep -q -w jffs2; then
    echo "Disabled"
else
    echo "Enabled"
fi