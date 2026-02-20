#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    false
    exit $?
fi

if [[ "$(id -u)" -ne 0 ]]; then
    false
    exit $?
fi

BANNER_TEXT="$1"

if (
    printf "%s\n" "$BANNER_TEXT" > /etc/issue.net &&
    chown root:root /etc/issue.net &&
    chmod 0644 /etc/issue.net
); then
    true
else
    false
fi