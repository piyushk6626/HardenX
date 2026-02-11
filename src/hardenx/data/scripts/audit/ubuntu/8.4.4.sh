#!/bin/bash

if ! command -v auditctl &> /dev/null; then
    echo "Not Installed"
    exit 0
fi

if auditctl -l 2>/dev/null | grep -q -- '-k time-change'; then
    echo "Enabled"
else
    echo "Disabled"
fi