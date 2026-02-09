#!/usr/bin/env bash

if ! systemctl list-unit-files --all --type=service | grep -qE '^(dovecot|cyrus-imapd)\.service'; then
    echo "Not Installed"
    exit 0
fi

if systemctl is-enabled dovecot.service &>/dev/null || systemctl is-enabled cyrus-imapd.service &>/dev/null; then
    echo "Enabled"
else
    echo "Disabled"
fi