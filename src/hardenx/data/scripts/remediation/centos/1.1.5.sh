#!/usr/bin/env bash

if echo "install jffs2 /bin/true" > /etc/modprobe.d/jffs2.conf; then
    modprobe -r jffs2 &>/dev/null
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi
