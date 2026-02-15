#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
    false
    exit 1
fi

if [[ $# -ne 1 ]]; then
    false
    exit 1
fi

LOG_GROUP="$1"
AUDITD_CONF="/etc/audit/auditd.conf"

if [[ ! -f "$AUDITD_CONF" ]]; then
    false
    exit 1
fi

if grep -qE '^[[:space:]]*log_group[[:space:]]*=' "$AUDITD_CONF"; then
    sed -i -E "s/^[[:space:]]*log_group[[:space:]]*=.*$/log_group = ${LOG_GROUP}/" "$AUDITD_CONF"
    if [[ $? -ne 0 ]]; then
        false
        exit 1
    fi
else
    echo "log_group = ${LOG_GROUP}" >> "$AUDITD_CONF"
    if [[ $? -ne 0 ]]; then
        false
        exit 1
    fi
fi

if ! systemctl restart auditd &>/dev/null; then
    false
    exit 1
fi

true