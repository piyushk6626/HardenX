#!/bin/bash

count=$(awk -F: '$2 != "x" {count++} END {print count+0}' /etc/passwd)

if [ "$count" -eq 0 ]; then
    printf "All accounts use shadowed passwords.\n"
else
    printf "%d account(s) do not use shadowed passwords:\n" "$count"
    awk -F: '$2 != "x" {print " - " $1}' /etc/passwd
fi