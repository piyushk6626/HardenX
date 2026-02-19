#!/bin/bash

is_enabled=false
is_active=false

if systemctl is-enabled --quiet systemd-timesyncd; then
    is_enabled=true
fi

if systemctl is-active --quiet systemd-timesyncd; then
    is_active=true
fi

if [[ "$is_enabled" == true && "$is_active" == true ]]; then
    echo "enabled_and_running"
elif [[ "$is_enabled" == true && "$is_active" == false ]]; then
    echo "enabled_not_running"
elif [[ "$is_enabled" == false && "$is_active" == true ]]; then
    echo "disabled_running"
else
    echo "disabled_not_running"
fi