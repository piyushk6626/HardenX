#!/bin/bash

if ! lsmod | grep -q '^tipc\s' && modprobe -n -v tipc 2>/dev/null | grep -q 'install /bin/true'; then
    echo "Disabled"
else
    echo "Enabled"
fi