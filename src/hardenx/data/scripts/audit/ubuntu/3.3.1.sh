#!/usr/bin/env bash

active_daemons=()

if systemctl is-active --quiet systemd-timesyncd && systemctl is-enabled --quiet systemd-timesyncd; then
    active_daemons+=("systemd-timesyncd")
fi

if systemctl is-active --quiet chronyd && systemctl is-enabled --quiet chronyd; then
    active_daemons+=("chrony")
fi

if systemctl is-active --quiet ntpd && systemctl is-enabled --quiet ntpd; then
    active_daemons+=("ntp")
fi

if [[ ${#active_daemons[@]} -eq 1 ]]; then
    echo "${active_daemons[0]}"
else
    echo "None"
fi