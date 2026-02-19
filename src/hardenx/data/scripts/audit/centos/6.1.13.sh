#!/usr/bin/env bash

gracetime=$(sshd -T 2>/dev/null | grep '^logingracetime ' | awk '{print $2}')

if [[ -n "$gracetime" ]]; then
    printf "SSH LoginGraceTime is set to: %s seconds\n" "$gracetime"
else
    printf "Could not determine SSH LoginGraceTime setting.\n"
fi