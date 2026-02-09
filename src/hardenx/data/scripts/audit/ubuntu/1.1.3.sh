#!/usr/bin/env bash

if modprobe --showconfig | grep -q -E '^\s*(install\s+hfs\s+/bin/(true|false)|blacklist\s+hfs)\s*$' ; then
    echo "disabled"
else
    echo "enabled"
fi