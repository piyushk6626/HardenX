#!/bin/bash

if modprobe -n -v udf 2>/dev/null | grep -q 'install /bin/true' && ! lsmod | grep -q udf; then
    echo "Disabled"
else
    echo "Enabled"
fi