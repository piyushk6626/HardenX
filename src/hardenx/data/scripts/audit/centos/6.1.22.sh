#!/usr/bin/env bash

usepam=$(sshd -T 2>/dev/null | awk '/^usepam/i {print $2}')

if [[ -n "$usepam" ]]; then
    printf "UsePAM is set to: %s\n" "$usepam"
else
    printf "no"
fi