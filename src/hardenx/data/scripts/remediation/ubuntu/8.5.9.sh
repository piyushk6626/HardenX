#!/bin/bash

if [ "$#" -ne 1 ]; then
    exit 1
fi

OWNER_USER="$1"

chown "$OWNER_USER" \
    /sbin/auditctl \
    /sbin/aureport \
    /sbin/ausearch \
    /sbin/autrace \
    /sbin/auditd &>/dev/null

exit_code=$?

if [ $exit_code -eq 0 ]; then
    true
else
    false
fi