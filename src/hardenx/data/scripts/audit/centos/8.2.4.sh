#!/bin/bash

limit=$(auditctl -s | awk '/backlog_limit/ {print $2}')

if [[ -n "$limit" ]]; then
    printf "Current audit backlog limit: %s\n" "$limit"
else
    printf "Could not determine audit backlog limit.\n"
fi