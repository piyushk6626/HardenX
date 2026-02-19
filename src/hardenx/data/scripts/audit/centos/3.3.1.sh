#!/usr/bin/env bash

systemctl is-enabled chronyd &>/dev/null
chrony_status=$?

systemctl is-enabled ntpd &>/dev/null
ntp_status=$?

if [[ $chrony_status -eq 0 && $ntp_status -eq 0 ]]; then
    echo "multiple"
elif [[ $chrony_status -eq 0 ]]; then
    echo "chrony"
elif [[ $ntp_status -eq 0 ]]; then
    echo "ntp"
else
    echo "none"
fi