#!/usr/bin/env bash

if modprobe --show-config | grep -Pq '^\s*install\s+cramfs\s+(/bin/true|/bin/false)' && ! lsmod | grep -q "^cramfs "; then
    echo "Disabled"
else
    echo "Enabled"
fi