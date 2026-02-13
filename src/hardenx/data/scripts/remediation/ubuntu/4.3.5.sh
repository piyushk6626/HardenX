#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [[ $# -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"
CONF_FILE="/etc/sysctl.d/10-ipv4-redirect-tuning.conf"

sysctl -w net.ipv4.conf.all.accept_redirects="$VALUE" &>/dev/null || { echo "false"; exit 1; }
sysctl -w net.ipv4.conf.default.accept_redirects="$VALUE" &>/dev/null || { echo "false"; exit 1; }

cat <<EOF > "$CONF_FILE" || { echo "false"; exit 1; }
net.ipv4.conf.all.accept_redirects = ${VALUE}
net.ipv4.conf.default.accept_redirects = ${VALUE}
EOF

echo "true"