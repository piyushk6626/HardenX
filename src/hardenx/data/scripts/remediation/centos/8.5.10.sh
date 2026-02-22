#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ -z "$1" ]]; then
    echo "false"
    exit 1
fi

GROUP_NAME="$1"

if chgrp -- "$GROUP_NAME" \
    /sbin/auditctl \
    /sbin/aureport \
    /sbin/ausearch \
    /sbin/autrace \
    /sbin/augenrules &> /dev/null; then
    echo "true"
else
    echo "false"
fi