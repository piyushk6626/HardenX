#!/usr/bin/env bash

if grep -qsrhE '^\s*install\s+jffs2\s+/bin/true\s*$' /etc/modprobe.d/ /etc/modprobe.conf; then
    echo "Disabled"
else
    echo "Enabled"
fi