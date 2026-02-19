#!/bin/bash

if systemctl is-enabled --quiet rsyslog && systemctl is-active --quiet rsyslog; then
    echo "enabled"
else
    echo "disabled"
fi