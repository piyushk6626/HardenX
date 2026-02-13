#!/usr/bin/env bash

fail() {
    echo "false"
    exit 1
}

trap fail ERR SIGINT SIGTERM

if [[ "$EUID" -ne 0 ]]; then
   exit 1
fi

if [[ "$#" -ne 1 ]]; then
    exit 1
fi

MACS_LIST="$1"
SSHD_CONFIG="/etc/ssh/sshd_config"

if [[ ! -w "$SSHD_CONFIG" ]]; then
    exit 1
fi

if grep -qE '^\s*#?\s*MACs\s+' "$SSHD_CONFIG"; then
    sed -i -E "s/^\s*#?\s*MACs\s+.*/MACs $MACS_LIST/" "$SSHD_CONFIG"
else
    echo "MACs $MACS_LIST" >> "$SSHD_CONFIG"
fi

sshd -t -q

if command -v systemctl &> /dev/null; then
    systemctl restart sshd
elif command -v service &> /dev/null; then
    service sshd restart
else
    exit 1
fi

echo "true"