#!/bin/bash

# Check if the cups.service unit exists
systemctl status cups.service &> /dev/null

if [ $? -eq 4 ]; then
    # Unit not found, which we treat as not installed
    echo "Not Installed"
else
    # Unit found, check if it is enabled
    systemctl is-enabled cups.service
fi