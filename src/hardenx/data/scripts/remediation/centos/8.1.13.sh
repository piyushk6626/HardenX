#!/usr/bin/env bash

if [[ "$1" != "Compliant" ]]; then
    echo "false"
    exit 1
fi

if find /var/log -type f -exec chmod o-rwx {} + && find /var/log -type f -exec chown root:root {} + &>/dev/null; then
    echo "true"
else
    echo "false"
fi