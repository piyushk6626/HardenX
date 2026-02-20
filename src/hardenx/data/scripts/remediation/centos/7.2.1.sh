#!/usr/bin/env bash

if [[ "$1" != "Not Listed" ]]; then
    echo "false"
    exit 1
fi

if sed -i -e '\#/sbin/nologin#d' -e '\#/usr/sbin/nologin#d' /etc/shells 2>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi