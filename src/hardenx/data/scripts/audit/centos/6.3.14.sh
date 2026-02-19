#!/usr/bin/env bash

maxclass=$(awk -F= '/^maxclass/ {gsub(/[[:space:]]/,"", $2); print $2}' /etc/security/pwquality.conf)

if [[ -n "$maxclass" ]]; then
    printf "Password maxclass setting: %s\n" "$maxclass"
else
    printf "maxclass is not set in /etc/security/pwquality.conf\n"
fi