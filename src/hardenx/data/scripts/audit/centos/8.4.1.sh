#!/usr/bin/env bash

# This script requires root privileges to run auditctl
if [[ $EUID -ne 0 ]]; then
   # In a non-root context, the rules cannot be checked, so they are considered disabled.
   echo "Disabled"
   exit 1
fi

rules=$(auditctl -l 2>/dev/null)

if echo "$rules" | grep -q -- "-w /etc/sudoers -p wa -k scope" && \
   echo "$rules" | grep -q -- "-w /etc/sudoers.d -p wa -k scope"; then
    echo "Enabled"
else
    echo "Disabled"
fi