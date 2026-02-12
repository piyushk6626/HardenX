#!/bin/bash

if [[ "$1" == "enabled-active" ]]; then
    if systemctl enable cron.service &>/dev/null && systemctl start cron.service &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi