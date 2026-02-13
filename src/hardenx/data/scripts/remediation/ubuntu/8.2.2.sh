#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    exit 1
fi

if [[ "$1" == "enabled-active" ]]; then
    systemctl enable --now auditd
else
    exit 1
fi