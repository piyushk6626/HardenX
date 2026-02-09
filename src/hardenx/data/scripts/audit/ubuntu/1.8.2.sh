#!/bin/bash

if findmnt --noheadings --output OPTIONS /var/log/audit | grep -q '\bnodev\b'; then
    echo "Enabled"
else
    echo "Disabled"
fi