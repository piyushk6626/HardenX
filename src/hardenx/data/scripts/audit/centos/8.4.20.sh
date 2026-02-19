#!/bin/bash

enabled=$(auditctl -s | awk '/enabled/ {print $2}')

if [[ -n "$enabled" ]]; then
    if [[ "$enabled" -eq 1 ]]; then
        printf "Auditing is enabled.\n"
    else
        printf "Auditing is disabled.\n"
    fi
else
    printf "Could not determine auditing status.\n"
fi