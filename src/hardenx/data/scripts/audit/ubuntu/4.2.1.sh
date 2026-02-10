#!/bin/bash

if lsmod | grep -q '^dccp\b'; then
    echo "loaded"
elif modprobe --showconfig | grep -qE '^\s*(install\s+dccp\s+/bin/(true|false)|blacklist\s+dccp\b)'; then
    echo "disabled"
else
    echo "enabled"
fi