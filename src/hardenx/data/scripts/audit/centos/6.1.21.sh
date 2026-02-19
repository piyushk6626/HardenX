#!/usr/bin/env bash

permit_env=$(sshd -T | grep -i '^permituserenvironment' | awk '{print $2}')

if [[ -n "$permit_env" ]]; then
    printf "PermitUserEnvironment is set to: %s\n" "$permit_env"
else
    printf "Could not determine PermitUserEnvironment setting.\n"
fi