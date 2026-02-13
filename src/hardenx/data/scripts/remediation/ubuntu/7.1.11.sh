#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   false
   exit 1
fi

if [[ "$1" != "secure" ]]; then
   false
   exit 1
fi

if [ -f "/root/.bashrc" ]; then
    CONFIG_FILE="/root/.bashrc"
elif [ -f "/root/.profile" ]; then
    CONFIG_FILE="/root/.profile"
else
    CONFIG_FILE="/root/.bashrc"
fi

if ! touch "$CONFIG_FILE"; then
    false
    exit 1
fi

SECURE_PATH_DEF="export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'"

if ! sed -i -E '/^ *(export +)?PATH=.*/d' "$CONFIG_FILE"; then
    false
    exit 1
fi

if ! echo "$SECURE_PATH_DEF" >> "$CONFIG_FILE"; then
    false
    exit 1
fi

true