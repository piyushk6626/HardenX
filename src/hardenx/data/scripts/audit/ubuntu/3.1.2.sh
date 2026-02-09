#!/bin/bash

status=$(systemctl is-enabled avahi-daemon 2>/dev/null)
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "$status"
else
    echo "not installed"
fi