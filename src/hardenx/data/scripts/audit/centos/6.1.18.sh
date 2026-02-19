#!/usr/bin/env bash

maxstartups=$(sshd -T | grep -i '^maxstartups' | awk '{print $2}')

if [[ -n "$maxstartups" ]]; then
    printf "SSH MaxStartups is set to: %s\n" "$maxstartups"
else
    printf "Could not determine SSH MaxStartups setting.\n"
fi