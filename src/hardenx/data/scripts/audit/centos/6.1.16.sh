#!/usr/bin/env bash

maxauth=$(sshd -T | grep -i '^maxauthtries' | awk '{print $2}')

if [[ -n "$maxauth" ]]; then
    printf "SSH MaxAuthTries is set to: %s\n" "$maxauth"
else
    printf "Could not determine SSH MaxAuthTries setting.\n"
fi