#!/bin/bash

if ! lsmod | grep -q '^overlay ' && [[ "$(modprobe -n -v overlayfs 2>/dev/null)" == "install /bin/true" ]]; then
    echo "disabled"
else
    echo "enabled"
fi