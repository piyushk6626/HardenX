#!/bin/bash

if [[ "$1" != "Enabled and Active" ]]; then
    echo "false"
    exit 0
fi

sudo systemctl unmask rsyslog.service &>/dev/null
sudo systemctl enable rsyslog.service &>/dev/null
sudo systemctl start rsyslog.service &>/dev/null

ENABLED_STATUS=$(systemctl is-enabled rsyslog.service 2>/dev/null)
ACTIVE_STATUS=$(systemctl is-active rsyslog.service 2>/dev/null)

if [[ "${ENABLED_STATUS}" == "enabled" && "${ACTIVE_STATUS}" == "active" ]]; then
    echo "true"
else
    echo "false"
fi