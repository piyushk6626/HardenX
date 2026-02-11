#!/usr/bin/env bash

is_compliant=1

while IFS=: read -r _ _ uid _ _ home shell; do
    if [[ "$uid" -ge 1000 && "$shell" != "/sbin/nologin" && "$shell" != "/bin/false" ]]; then
        if [[ ! -d "$home" ]]; then
            is_compliant=0
            break
        fi
    fi
done < /etc/passwd

if [[ "$is_compliant" -eq 1 ]]; then
    echo "Compliant"
else
    echo "Non-Compliant"
fi