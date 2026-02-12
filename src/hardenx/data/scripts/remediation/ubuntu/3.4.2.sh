#!/usr/bin/env bash

if [[ "$#" -ne 1 ]] || [[ "$1" != "Enabled and Active" ]]; then
    echo "false"
    exit 1
fi

if systemctl unmask systemd-timesyncd &> /dev/null && \
   systemctl enable systemd-timesyncd &> /dev/null && \
   systemctl start systemd-timesyncd &> /dev/null && \
   systemctl is-enabled --quiet systemd-timesyncd && \
   systemctl is-active --quiet systemd-timesyncd; then
    echo "true"
else
    echo "false"
fi