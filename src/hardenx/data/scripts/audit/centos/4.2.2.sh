#!/usr/bin/env bash

if ! lsmod | grep -q '^tipc ' && modprobe --showconfig | grep -qP '^\s*(install\s+tipc\s+/bin/true|blacklist\s+tipc\b)'; then
    echo "Disabled"
else
    echo "Enabled"
fi
