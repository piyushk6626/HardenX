#!/bin/bash

if [[ "$1" == "Enabled and Active" ]]; then
    if systemctl enable systemd-journald &>/dev/null && systemctl start systemd-journald &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi