#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/ssh/sshd_config"
PERMIT_VALUE="$1"
KEY="PermitEmptyPasswords"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "false"
    exit 1
fi

if grep -qE "^\s*#?\s*${KEY}" "$CONFIG_FILE"; then
    # The key exists (commented or uncommented), so replace it.
    sed -i "s/^\s*#?\s*${KEY}.*/${KEY} ${PERMIT_VALUE}/" "$CONFIG_FILE"
    if [ $? -ne 0 ]; then
        echo "false"
        exit 1
    fi
else
    # The key does not exist, so append it.
    echo "${KEY} ${PERMIT_VALUE}" >> "$CONFIG_FILE"
    if [ $? -ne 0 ]; then
        echo "false"
        exit 1
    fi
fi

systemctl restart sshd
if [ $? -ne 0 ]; then
    echo "false"
    exit 1
fi

echo "true"
exit 0