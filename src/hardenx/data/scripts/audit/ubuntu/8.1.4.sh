#!/bin/bash

if systemctl is-active --quiet rsyslog; then
    echo "enabled"
else
    echo "disabled"
fi