#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

OWNERSHIP_SPEC=$1

if ! [[ "$OWNERSHIP_SPEC" =~ ^[^:]+:[^:]+$ ]]; then
    echo "false"
    exit 1
fi

NEW_OWNER=$(echo "$OWNERSHIP_SPEC" | cut -d: -f1)
NEW_GROUP=$(echo "$OWNERSHIP_SPEC" | cut -d: -f2)

if ! id -u "$NEW_OWNER" &>/dev/null || ! getent group "$NEW_GROUP" &>/dev/null; then
    echo "false"
    exit 1
fi

if find / -xdev \( -nouser -o -nogroup \) -print0 2>/dev/null | xargs -0 -r chown -- "$OWNERSHIP_SPEC"; then
    echo "true"
else
    echo "false"
fi