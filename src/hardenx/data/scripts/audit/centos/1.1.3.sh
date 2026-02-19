#!/bin/bash

if modprobe --show-config | grep -Pq '^\s*install\s+hfs\s+/bin/true' && ! lsmod | grep -wq '^hfs'; then
    echo "disabled"
else
    echo "enabled"
fi