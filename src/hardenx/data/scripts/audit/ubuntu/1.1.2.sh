#!/usr/bin/env bash

if modprobe --show-config | grep -q -E '^(\s*blacklist\s+freevxfs|\s*install\s+freevxfs\s+/bin/(true|false))'; then
    echo "disabled"
else
    echo "enabled"
fi