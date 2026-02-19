#!/bin/bash

if modprobe --show-config | grep -Pq '^\s*(install\s+rds\s+/bin/(true|false)|blacklist\s+rds\b)'; then
    echo "disabled"
elif lsmod | grep -wq rds &>/dev/null; then
    echo "enabled"
else
    echo "disabled"
fi