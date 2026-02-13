#!/bin/bash

if [[ "$1" == "disabled" ]]; then
    if systemctl stop rsyslog &>/dev/null && systemctl disable rsyslog &>/dev/null; then
        true
    else
        false
    fi
fi