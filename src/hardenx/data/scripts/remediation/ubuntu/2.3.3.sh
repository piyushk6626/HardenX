#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

spec="$1"
owner_group="${spec% *}"
permissions="${spec#* }"

if [[ "$owner_group" == "$spec" ]] || [[ "$permissions" == "$spec" ]]; then
    echo "false"
    exit 1
fi

if chown "$owner_group" /etc/motd &>/dev/null && chmod "$permissions" /etc/motd &>/dev/null; then
    echo "true"
else
    echo "false"
fi