#!/bin/bash

if modprobe --showconfig | grep -qE '^\s*install\s+udf\s+/bin/true\s*$'; then
    echo "disabled"
else
    echo "enabled"
fi