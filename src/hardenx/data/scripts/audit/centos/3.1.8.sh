#!/usr/bin/env bash

if systemctl is-enabled dovecot &>/dev/null || systemctl is-enabled cyrus-imapd &>/dev/null; then
  echo "Enabled"
else
  echo "Disabled"
fi