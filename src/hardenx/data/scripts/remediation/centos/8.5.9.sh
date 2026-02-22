#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "false"
    exit 1
fi

OWNER="$1"
FILES=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
    "/sbin/audispd"
    "/sbin/augenrules"
)

if chown "$OWNER" "${FILES[@]}" &>/dev/null; then
    echo "true"
else
    echo "false"
fi