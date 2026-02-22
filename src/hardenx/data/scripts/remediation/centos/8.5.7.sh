#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

GROUP_NAME="$1"

if ! getent group "${GROUP_NAME}" &>/dev/null; then
    echo "false"
    exit 1
fi

if [[ ! -d "/etc/audit/" ]]; then
    echo "false"
    exit 1
fi

if chgrp -R -- "${GROUP_NAME}" /etc/audit/ &>/dev/null; then
    echo "true"
else
    echo "false"
fi