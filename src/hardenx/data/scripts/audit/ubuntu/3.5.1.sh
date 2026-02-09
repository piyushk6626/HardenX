#!/usr/bin/env bash

if systemctl cat chrony.service &> /dev/null; then
    SERVICE_NAME="chrony.service"
elif systemctl cat chronyd.service &> /dev/null; then
    SERVICE_NAME="chronyd.service"
else
    echo "not installed"
    exit 0
fi

if systemctl is-enabled --quiet "$SERVICE_NAME"; then
    echo "enabled"
else
    echo "disabled"
fi