#!/usr/bin/env bash

permit_root=$(sshd -T | grep -i '^permitrootlogin' | awk '{print $2}')

if [[ -n "$permit_root" ]]; then
    printf "PermitRootLogin is set to: %s\n" "$permit_root"
else
    printf "Could not determine PermitRootLogin setting.\n"
fi